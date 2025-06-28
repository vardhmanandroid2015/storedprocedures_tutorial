-- Step 1: Create the necessary tables
-- Create the employees table if it doesn't exist
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    department VARCHAR(50)
);

-- Insert some sample data into employees
INSERT INTO employees (name, salary, department) VALUES
('John Doe', 50000.00, 'IT'),
('Jane Smith', 60000.00, 'HR'),
('Bob Johnson', 55000.00, 'IT')
ON CONFLICT (id) DO NOTHING; -- Avoid re-inserting if run multiple times

-- Create the salary_audit_log table if it doesn't exist
CREATE TABLE IF NOT EXISTS salary_audit_log (
    log_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    old_salary NUMERIC(10, 2),
    new_salary NUMERIC(10, 2) NOT NULL,
    change_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments for better understanding of the tables
COMMENT ON TABLE employees IS 'Stores employee information.';
COMMENT ON COLUMN employees.id IS 'Unique identifier for the employee.';
COMMENT ON COLUMN employees.salary IS 'Current salary of the employee.';

COMMENT ON TABLE salary_audit_log IS 'Logs changes to employee salaries.';
COMMENT ON COLUMN salary_audit_log.employee_id IS 'ID of the employee whose salary changed.';
COMMENT ON COLUMN salary_audit_log.old_salary IS 'Salary before the change.';
COMMENT ON COLUMN salary_audit_log.new_salary IS 'Salary after the change.';
COMMENT ON COLUMN salary_audit_log.change_date IS 'Timestamp of when the salary change was logged.';

-- Step 2: Define the trigger function
-- This function will be executed by the trigger to log salary changes.
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new record into the audit log table using OLD and NEW special variables
    -- OLD.id refers to the ID of the row *before* the update
    -- OLD.salary refers to the salary of the row *before* the update
    -- NEW.salary refers to the salary of the row *after* the update
    -- NOW() gets the current timestamp
    INSERT INTO salary_audit_log (employee_id, old_salary, new_salary, change_date)
    VALUES (OLD.id, OLD.salary, NEW.salary, NOW());

    -- For AFTER row-level triggers, it's common to RETURN NEW;
    -- This indicates that the (potentially modified) new row should be used by the calling statement.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add comments for better understanding of the trigger function
COMMENT ON FUNCTION log_salary_change() IS 'Trigger function to log salary changes in the salary_audit_log table.';

-- Step 3: Create the trigger itself
-- This statement links the 'log_salary_change' function to the 'employees' table.
-- AFTER UPDATE OF salary: The trigger fires after an UPDATE operation, specifically when the 'salary' column changes.
-- ON employees: Specifies the table on which the trigger will operate.
-- FOR EACH ROW: The trigger will execute for each individual row affected by the UPDATE.
-- EXECUTE FUNCTION log_salary_change(): Calls the previously defined function.
CREATE TRIGGER salary_change_audit
AFTER UPDATE OF salary ON employees
FOR EACH ROW
EXECUTE FUNCTION log_salary_change();

-- Add comments for better understanding of the trigger
COMMENT ON TRIGGER salary_change_audit ON employees IS 'Audits salary changes by logging them into the salary_audit_log table.';

-- Step 4: Test the trigger

-- 4.1: Check initial state of employees table (e.g., employee with id = 1)
SELECT id, name, salary FROM employees WHERE id = 1;

-- 4.2: Check initial state of the salary_audit_log table for this employee
SELECT * FROM salary_audit_log WHERE employee_id = 1;

-- 4.3: Update John Doe's salary
-- This action should cause the 'salary_change_audit' trigger to fire
UPDATE employees
SET salary = 52000.00
WHERE id = 1;

-- 4.4: Verify the updated salary in the employees table
SELECT id, name, salary FROM employees WHERE id = 1;

-- 4.5: Check the salary_audit_log table to confirm the trigger inserted a log entry
SELECT employee_id, old_salary, new_salary, change_date FROM salary_audit_log WHERE employee_id = 1;

-- 4.6: Perform another update to see multiple log entries
UPDATE employees
SET salary = 53500.00
WHERE id = 1;

-- 4.7: Check the log again to see the new entry
SELECT employee_id, old_salary, new_salary, change_date FROM salary_audit_log WHERE employee_id = 1;
