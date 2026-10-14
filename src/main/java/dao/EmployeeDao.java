package dao;

import model.Employee;
import util.DBConnect;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmployeeDao {

    /**
     * Idempotent schema upgrade for existing installations. A SQL migration is also
     * checked into database/employee_profile_migration.sql for manual deployment.
     */
    public boolean ensureProfileSchema() {
        String ddl =
            "IF COL_LENGTH(N'dbo.Employee', N'family_name') IS NULL ALTER TABLE dbo.Employee ADD family_name NVARCHAR(100) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'given_name') IS NULL ALTER TABLE dbo.Employee ADD given_name NVARCHAR(100) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'date_of_birth') IS NULL ALTER TABLE dbo.Employee ADD date_of_birth DATE NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'identity_number') IS NULL ALTER TABLE dbo.Employee ADD identity_number NVARCHAR(30) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'region') IS NULL ALTER TABLE dbo.Employee ADD region NVARCHAR(150) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'permanent_address') IS NULL ALTER TABLE dbo.Employee ADD permanent_address NVARCHAR(500) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'bank_name') IS NULL ALTER TABLE dbo.Employee ADD bank_name NVARCHAR(150) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'bank_account_number') IS NULL ALTER TABLE dbo.Employee ADD bank_account_number NVARCHAR(50) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'avatar_content_type') IS NULL ALTER TABLE dbo.Employee ADD avatar_content_type VARCHAR(50) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'avatar_data') IS NULL ALTER TABLE dbo.Employee ADD avatar_data VARBINARY(MAX) NULL; " +
            "IF COL_LENGTH(N'dbo.Employee', N'account_id') IS NULL ALTER TABLE dbo.Employee ADD account_id INT NULL;";
        String backfillNames =
            "UPDATE dbo.Employee SET " +
            "family_name = CASE WHEN NULLIF(LTRIM(RTRIM(family_name)), N'') IS NOT NULL THEN family_name " +
            "WHEN CHARINDEX(N' ', LTRIM(RTRIM(ISNULL(name, N'')))) > 0 " +
            "THEN LEFT(LTRIM(RTRIM(name)), LEN(LTRIM(RTRIM(name))) - CHARINDEX(N' ', REVERSE(LTRIM(RTRIM(name))))) " +
            "ELSE LTRIM(RTRIM(ISNULL(name, N''))) END, " +
            "given_name = CASE WHEN NULLIF(LTRIM(RTRIM(given_name)), N'') IS NOT NULL THEN given_name " +
            "WHEN CHARINDEX(N' ', LTRIM(RTRIM(ISNULL(name, N'')))) > 0 " +
            "THEN RIGHT(LTRIM(RTRIM(name)), CHARINDEX(N' ', REVERSE(LTRIM(RTRIM(name)))) - 1) ELSE N'' END " +
            "WHERE family_name IS NULL OR given_name IS NULL";
        String linkAccounts =
            "IF OBJECT_ID(N'dbo.Account', N'U') IS NOT NULL " +
            "UPDATE e SET account_id = a.id FROM dbo.Employee e JOIN dbo.Account a " +
            "ON LTRIM(RTRIM(a.fullname)) = LTRIM(RTRIM(e.name)) " +
            "WHERE e.account_id IS NULL " +
            "AND (SELECT COUNT(*) FROM dbo.Account aa WHERE LTRIM(RTRIM(aa.fullname))=LTRIM(RTRIM(e.name))) = 1 " +
            "AND (SELECT COUNT(*) FROM dbo.Employee ee WHERE LTRIM(RTRIM(ee.name))=LTRIM(RTRIM(e.name))) = 1";
        try (Connection conn = DBConnect.getConnection(); Statement stmt = conn.createStatement()) {
            stmt.execute(ddl);
            stmt.execute(backfillNames);
            stmt.execute(linkAccounts);
            return true;
        } catch (Exception e) {
            System.err.println("Không thể cập nhật schema hồ sơ nhân viên: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public List<Employee> getAll() {
        List<Employee> list = new ArrayList<>();
        if (!ensureProfileSchema()) return list;
        String sql = "SELECT id, account_id, name, family_name, given_name, email, phone, position, date_of_birth, " +
                     "identity_number, region, permanent_address, bank_name, bank_account_number, avatar_content_type " +
                     "FROM dbo.Employee ORDER BY id DESC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(readEmployee(rs, false));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Employee> searchEmployees(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return getAll();
        List<Employee> list = new ArrayList<>();
        if (!ensureProfileSchema()) return list;
        String pattern = "%" + keyword.trim() + "%";
        String sql = "SELECT id, account_id, name, family_name, given_name, email, phone, position, date_of_birth, " +
                     "identity_number, region, permanent_address, bank_name, bank_account_number, avatar_content_type " +
                     "FROM dbo.Employee WHERE name LIKE ? OR email LIKE ? OR ISNULL(phone, '') LIKE ? OR position LIKE ? " +
                     "OR ISNULL(identity_number, N'') LIKE ? OR ISNULL(region, N'') LIKE ? ORDER BY id DESC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, pattern); ps.setString(2, pattern); ps.setString(3, pattern);
            ps.setNString(4, pattern); ps.setNString(5, pattern); ps.setNString(6, pattern);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) list.add(readEmployee(rs, false)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean insert(Employee emp) {
        if (!ensureProfileSchema()) return false;
        String fullName = fullName(emp.getFamilyName(), emp.getGivenName());
        String sql = "INSERT INTO dbo.Employee (name, family_name, given_name, email, phone, position, date_of_birth, " +
                     "identity_number, region, permanent_address, bank_name, bank_account_number) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            bindProfile(ps, emp, fullName, false);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean delete(int id) {
        if (!ensureProfileSchema()) return false;
        String sql = "DELETE FROM dbo.Employee WHERE id = ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id); return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public Employee getById(int id) {
        if (!ensureProfileSchema()) return null;
        String sql = "SELECT * FROM dbo.Employee WHERE id = ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return readEmployee(rs, true); }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public Employee getByAccountId(int accountId, String accountFullName) {
        if (!ensureProfileSchema()) return null;
        String byAccount = "SELECT * FROM dbo.Employee WHERE account_id = ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(byAccount)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return readEmployee(rs, true);
            }
        } catch (Exception e) { e.printStackTrace(); }

        if (accountFullName == null || accountFullName.trim().isEmpty()) return null;
        String byName = "SELECT TOP 1 * FROM dbo.Employee WHERE LTRIM(RTRIM(name)) = LTRIM(RTRIM(?)) ORDER BY id DESC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(byName)) {
            ps.setNString(1, accountFullName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Employee emp = readEmployee(rs, true);
                    try (PreparedStatement link = conn.prepareStatement(
                            "UPDATE dbo.Employee SET account_id=? WHERE id=? AND account_id IS NULL")) {
                        link.setInt(1, accountId);
                        link.setInt(2, emp.getId());
                        link.executeUpdate();
                    }
                    return emp;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean update(Employee emp) {
        if (!ensureProfileSchema()) return false;
        String fullName = fullName(emp.getFamilyName(), emp.getGivenName());
        String sql = "UPDATE dbo.Employee SET name=?, family_name=?, given_name=?, email=?, phone=?, position=?, " +
                     "date_of_birth=?, identity_number=?, region=?, permanent_address=?, bank_name=?, bank_account_number=? " +
                     "WHERE id=?";
        try (Connection conn = DBConnect.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    bindProfile(ps, emp, fullName, true);
                    if (ps.executeUpdate() != 1) { conn.rollback(); return false; }
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.Account SET fullname=? WHERE id=(SELECT account_id FROM dbo.Employee WHERE id=?)")) {
                    ps.setNString(1, fullName);
                    ps.setInt(2, emp.getId());
                    ps.executeUpdate();
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally { conn.setAutoCommit(true); }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateAvatar(int employeeId, byte[] imageData, String contentType) {
        if (!ensureProfileSchema() || imageData == null || imageData.length == 0) return false;
        String sql = "UPDATE dbo.Employee SET avatar_data=?, avatar_content_type=? WHERE id=?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBytes(1, imageData); ps.setString(2, contentType); ps.setInt(3, employeeId);
            return ps.executeUpdate() == 1;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    private void bindProfile(PreparedStatement ps, Employee emp, String fullName, boolean includeId) throws SQLException {
        ps.setNString(1, fullName);
        ps.setNString(2, emp.getFamilyName().trim());
        ps.setNString(3, emp.getGivenName().trim());
        ps.setNString(4, emp.getEmail().trim());
        ps.setString(5, emp.getPhone() == null ? "" : emp.getPhone().trim());
        ps.setNString(6, emp.getPosition().trim());
        if (emp.getDateOfBirth() == null) ps.setNull(7, Types.DATE); else ps.setDate(7, emp.getDateOfBirth());
        setNStringOrNull(ps, 8, emp.getIdentityNumber());
        setNStringOrNull(ps, 9, emp.getRegion());
        setNStringOrNull(ps, 10, emp.getPermanentAddress());
        setNStringOrNull(ps, 11, emp.getBankName());
        setNStringOrNull(ps, 12, emp.getBankAccountNumber());
        if (includeId) ps.setInt(13, emp.getId());
    }

    private void setNStringOrNull(PreparedStatement ps, int index, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) ps.setNull(index, Types.NVARCHAR);
        else ps.setNString(index, value.trim());
    }

    private String fullName(String familyName, String givenName) {
        String family = familyName == null ? "" : familyName.trim();
        String given = givenName == null ? "" : givenName.trim();
        return (family + " " + given).trim();
    }

    private Employee readEmployee(ResultSet rs, boolean includeAvatarData) throws SQLException {
        Employee e = new Employee();
        e.setId(rs.getInt("id"));
        int accountId = rs.getInt("account_id");
        e.setAccountId(rs.wasNull() ? null : accountId);
        e.setName(rs.getNString("name"));
        e.setFamilyName(rs.getNString("family_name"));
        e.setGivenName(rs.getNString("given_name"));
        e.setEmail(rs.getString("email"));
        e.setPhone(rs.getString("phone"));
        e.setPosition(rs.getNString("position"));
        e.setDateOfBirth(rs.getDate("date_of_birth"));
        e.setIdentityNumber(rs.getNString("identity_number"));
        e.setRegion(rs.getNString("region"));
        e.setPermanentAddress(rs.getNString("permanent_address"));
        e.setBankName(rs.getNString("bank_name"));
        e.setBankAccountNumber(rs.getNString("bank_account_number"));
        e.setAvatarContentType(rs.getString("avatar_content_type"));
        if (includeAvatarData) e.setAvatarData(rs.getBytes("avatar_data"));
        return e;
    }
}
