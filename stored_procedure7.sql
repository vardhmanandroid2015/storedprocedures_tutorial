-- Function that returns all employees with salary above a threshold
CREATE OR REPLACE FUNCTION get_high_earners(min_salary NUMERIC)
RETURNS TABLE(emp_name TEXT, emp_salary NUMERIC, emp_dept TEXT) AS $$
BEGIN
RETURN QUERY
SELECT name, salary, department
FROM employees
WHERE salary >= min_salary
ORDER BY salary DESC;
END;
$$ LANGUAGE plpgsql;

-- How to call it:
SELECT * FROM get_high_earners(55000);