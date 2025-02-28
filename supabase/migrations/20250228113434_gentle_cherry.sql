/*
  # Update organization access policies for superadmins

  1. Changes
    - Drop existing organization policies
    - Create new policies that allow superadmins to see all organizations
    - Maintain existing access for regular users and company admins

  2. Security
    - Superadmins can see and manage all organizations
    - Regular users can only see their own organization
    - Company admins can manage their own organization
*/

-- Drop existing organization policies
DROP POLICY IF EXISTS "organizations_read" ON organizations;
DROP POLICY IF EXISTS "organizations_write" ON organizations;

-- Create new organization policies
CREATE POLICY "organizations_superadmin_access"
  ON organizations
  FOR ALL
  TO authenticated
  USING (
    -- Superadmins can access all organizations
    EXISTS (
      SELECT 1 
      FROM employees e 
      WHERE e.id = auth.uid() 
      AND e.role = 'superadmin'
      LIMIT 1
    )
  );

CREATE POLICY "organizations_member_read"
  ON organizations
  FOR SELECT
  TO authenticated
  USING (
    -- Regular users can only see their organization
    EXISTS (
      SELECT 1 
      FROM employees e 
      WHERE e.id = auth.uid() 
      AND e.organization_id = organizations.id
      AND e.role != 'superadmin'
      LIMIT 1
    )
  );

CREATE POLICY "organizations_admin_write"
  ON organizations
  FOR ALL
  TO authenticated
  USING (
    -- Company admins can manage their organization
    EXISTS (
      SELECT 1 
      FROM employees e 
      WHERE e.id = auth.uid() 
      AND e.organization_id = organizations.id
      AND e.role = 'company_admin'
      LIMIT 1
    )
  );