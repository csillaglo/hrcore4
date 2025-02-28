-- Drop existing problematic policies
DROP POLICY IF EXISTS "employees_read_self" ON employees;
DROP POLICY IF EXISTS "employees_read_organization" ON employees;
DROP POLICY IF EXISTS "employees_write" ON employees;

-- Create simplified policies for employees table
CREATE POLICY "employees_basic_access"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    -- Users can read their own profile
    id = auth.uid()
    OR
    -- Users can read profiles in their organization (using a direct join)
    organization_id = (
      SELECT organization_id
      FROM employees
      WHERE id = auth.uid()
      LIMIT 1
    )
  );

CREATE POLICY "employees_admin_access"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    -- Admins have full access to employees in their organization
    EXISTS (
      SELECT 1
      FROM employees admin
      WHERE admin.id = auth.uid()
      AND admin.role IN ('superadmin', 'company_admin')
      AND (
        admin.role = 'superadmin'
        OR admin.organization_id = employees.organization_id
      )
      LIMIT 1
    )
  );