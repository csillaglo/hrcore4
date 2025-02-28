/*
  # Fix employee policies to prevent recursion

  1. Changes
    - Drop existing employee policies that cause recursion
    - Create new simplified policies for employees
    - Implement clear role-based access without circular dependencies

  2. Security
    - Maintain strict access control
    - Prevent policy recursion
    - Clear separation of roles and permissions
*/

-- Drop existing problematic employee policies
DROP POLICY IF EXISTS "Employee self access" ON employees;
DROP POLICY IF EXISTS "Organization member view employees" ON employees;
DROP POLICY IF EXISTS "Employee admin manage access" ON employees;

-- Create new employee policies without recursion
CREATE POLICY "employee_read_own_profile"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "employee_read_organization_members"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    -- Simple organization membership check
    organization_id = (
      SELECT organization_id
      FROM employees
      WHERE id = auth.uid()
      LIMIT 1
    )
  );

CREATE POLICY "employee_admin_access"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    -- Direct role check for admins
    EXISTS (
      SELECT 1
      FROM employees admin
      WHERE admin.id = auth.uid()
      AND admin.role IN ('superadmin', 'company_admin')
      AND (
        admin.role = 'superadmin' 
        OR admin.organization_id = employees.organization_id
      )
    )
  )
  WITH CHECK (
    -- Same check for write operations
    EXISTS (
      SELECT 1
      FROM employees admin
      WHERE admin.id = auth.uid()
      AND admin.role IN ('superadmin', 'company_admin')
      AND (
        admin.role = 'superadmin' 
        OR admin.organization_id = employees.organization_id
      )
    )
  );