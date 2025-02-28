/*
  # Fix organization policies

  1. Changes
    - Drop all existing organization policies
    - Create new simplified policies without recursion
    - Implement clear role-based access control

  2. Security
    - Maintain strict access control
    - Prevent policy recursion
    - Clear separation of roles and permissions
*/

-- Drop existing organization policies
DROP POLICY IF EXISTS "Superadmin full access" ON organizations;
DROP POLICY IF EXISTS "Organization member read access" ON organizations;
DROP POLICY IF EXISTS "Company admin manage access" ON organizations;

-- Create new organization policies
CREATE POLICY "organization_read_access"
  ON organizations
  FOR SELECT
  TO authenticated
  USING (
    -- Allow access if user is a member of the organization
    id IN (
      SELECT organization_id
      FROM employees
      WHERE employees.id = auth.uid()
    )
  );

CREATE POLICY "organization_write_access"
  ON organizations
  FOR ALL
  TO authenticated
  USING (
    -- Allow full access for superadmins and company admins
    EXISTS (
      SELECT 1
      FROM employees
      WHERE employees.id = auth.uid()
      AND employees.organization_id = organizations.id
      AND employees.role IN ('superadmin', 'company_admin')
    )
  )
  WITH CHECK (
    -- Additional check for write operations
    EXISTS (
      SELECT 1
      FROM employees
      WHERE employees.id = auth.uid()
      AND employees.organization_id = organizations.id
      AND employees.role IN ('superadmin', 'company_admin')
    )
  );