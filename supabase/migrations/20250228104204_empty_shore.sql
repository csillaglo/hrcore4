/*
  # Initial Schema Setup for Organization Management System

  1. New Tables
    - organizations
      - Basic organization information
    - employees
      - Employee information with role management
    - departments
      - Department management within organizations
    - employee_departments
      - Junction table for employee-department relationships

  2. Types
    - user_role: Enum for different user roles
    
  3. Security
    - RLS policies for each table based on user roles
    - Secure access patterns for different user types
*/

-- Create user_role enum
CREATE TYPE user_role AS ENUM ('employee', 'manager', 'company_admin', 'superadmin');

-- Create organizations table
CREATE TABLE organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  is_active boolean DEFAULT true,
  logo_url text,
  website text,
  address text
);

-- Create departments table
CREATE TABLE departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  is_active boolean DEFAULT true,
  description text
);

-- Create employees table (extends Supabase auth.users)
CREATE TABLE employees (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  organization_id uuid REFERENCES organizations(id),
  first_name text NOT NULL,
  last_name text NOT NULL,
  role user_role NOT NULL DEFAULT 'employee',
  email text NOT NULL,
  phone text,
  hire_date date DEFAULT CURRENT_DATE,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create employee_departments junction table
CREATE TABLE employee_departments (
  employee_id uuid REFERENCES employees(id) ON DELETE CASCADE,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (employee_id, department_id)
);

-- Enable RLS
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_departments ENABLE ROW LEVEL SECURITY;

-- Organizations policies
CREATE POLICY "Superadmins can do everything with organizations"
  ON organizations
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees WHERE id = auth.uid() AND role = 'superadmin'
  ));

CREATE POLICY "Company admins can view and edit their organization"
  ON organizations
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees 
    WHERE id = auth.uid() 
    AND role = 'company_admin' 
    AND organization_id = organizations.id
  ));

CREATE POLICY "Managers and employees can view their organization"
  ON organizations
  FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees 
    WHERE id = auth.uid() 
    AND organization_id = organizations.id
  ));

-- Departments policies
CREATE POLICY "Company admins can manage departments"
  ON departments
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees 
    WHERE id = auth.uid() 
    AND role = 'company_admin' 
    AND organization_id = departments.organization_id
  ));

CREATE POLICY "Managers can view departments"
  ON departments
  FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees 
    WHERE id = auth.uid() 
    AND organization_id = departments.organization_id
    AND role IN ('manager', 'company_admin')
  ));

-- Employees policies
CREATE POLICY "Users can view their own profile"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Company admins can manage employees in their organization"
  ON employees
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees admin
    WHERE admin.id = auth.uid() 
    AND admin.role = 'company_admin' 
    AND admin.organization_id = employees.organization_id
  ));

CREATE POLICY "Managers can view employees in their organization"
  ON employees
  FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees manager
    WHERE manager.id = auth.uid() 
    AND manager.role = 'manager' 
    AND manager.organization_id = employees.organization_id
  ));

-- Employee departments policies
CREATE POLICY "Company admins can manage employee departments"
  ON employee_departments
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM employees admin
    JOIN employees e ON e.id = employee_departments.employee_id
    WHERE admin.id = auth.uid() 
    AND admin.role = 'company_admin' 
    AND admin.organization_id = e.organization_id
  ));

CREATE POLICY "Users can view their own departments"
  ON employee_departments
  FOR SELECT
  TO authenticated
  USING (employee_id = auth.uid());