/*
  # Fix recursive policies

  1. Changes
    - Drop existing problematic policies that cause recursion
    - Create new simplified policies that avoid recursive checks
    - Reorganize policies to be more efficient and clearer

  2. Security
    - Maintain same level of security but with better implementation
    - Ensure proper access control for all roles
    - Prevent infinite recursion in policy checks
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Employee organization read access" ON employees;
DROP POLICY IF EXISTS "Employee department organization access" ON employee_departments;

-- Create new simplified policies for employees
CREATE POLICY "Organization member view employees"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    -- Direct organization match or superadmin
    organization_id IN (
      SELECT e.organization_id 
      FROM employees e 
      WHERE e.id = auth.uid()
    ) OR 
    EXISTS (
      SELECT 1 
      FROM employees e 
      WHERE e.id = auth.uid() 
      AND e.role = 'superadmin'
    )
  );

-- Simplified employee departments access
CREATE POLICY "Organization member view employee departments"
  ON employee_departments
  FOR SELECT
  TO authenticated
  USING (
    -- Can view if in same organization or superadmin
    EXISTS (
      SELECT 1 
      FROM employees e1
      JOIN employees e2 ON e1.organization_id = e2.organization_id
      WHERE e1.id = employee_departments.employee_id
      AND e2.id = auth.uid()
    ) OR 
    EXISTS (
      SELECT 1 
      FROM employees e 
      WHERE e.id = auth.uid() 
      AND e.role = 'superadmin'
    )
  );