-- Create a sample employees table
CREATE TABLE employees (
id SERIAL PRIMARY KEY,
name TEXT,
salary NUMERIC(10,2),
department TEXT
);
-- Insert some sample data
INSERT INTO employees (name, salary, department) VALUES
('John Doe', 50000, 'IT'),
('Jane Smith', 60000, 'HR'),
('Bob Johnson', 55000, 'IT'),
('Alice Brown', 70000, 'Finance');

-- Function to get employee count by department
CREATE OR REPLACE FUNCTION get_employee_count_by_dept(dept_name TEXT)
RETURNS INTEGER AS $$
DECLARE
emp_count INTEGER;
BEGIN
SELECT COUNT(*) INTO emp_count
FROM employees
WHERE department = dept_name;
RETURN emp_count;
END;
$$ LANGUAGE plpgsql;

-- How to call it:
SELECT get_employee_count_by_dept('IT');
SELECT get_employee_count_by_dept('HR');