/*
  # Add department_id column to employees table

  1. Changes
    - Add department_id column to employees table
    - Add foreign key constraint to departments table
    - Add index for better query performance
*/

-- Add department_id column to employees table
ALTER TABLE employees ADD COLUMN IF NOT EXISTS department_id uuid REFERENCES departments(id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_employees_department ON employees(department_id);

-- Add comment for documentation
COMMENT ON COLUMN employees.department_id IS 'The department this employee belongs to. Can be NULL for admins or employees not assigned to a specific department.';