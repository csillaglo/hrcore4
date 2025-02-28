/*
  # Fix employee admin policy table

  1. Changes
    - Fix incorrect table reference for employee admin policy
    - Re-create policy on correct table (employees)

  2. Security
    - Maintains proper access control
    - Ensures admin can manage employees
*/

-- Drop incorrect policy from departments table
DROP POLICY IF EXISTS "Employee admin manage access" ON departments;

-- Create correct policy on employees table
CREATE POLICY "Employee admin manage access"
  ON employees
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees WHERE id = auth.uid() AND organization_id = employees.organization_id AND role IN ('company_admin', 'superadmin')
    )
  );