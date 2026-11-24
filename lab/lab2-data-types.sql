-- Laborator 2

SET SERVEROUTPUT ON
SET SERVEROUTPUT OFF

-- I. Inregistrari (Record)

/* 1. Sa se steargă angajatul având codul 200 din tabelul EMP_PNU. Să se retină într-o variabilă de tip
RECORD codul, numele, salariul si departamentul acestui angajat (clauza RETURNING) . Să se
afiseze înregistrarea respectivă. Rollback.
*/

DECLARE
    TYPE date_angajat IS RECORD (
        cod emp_pnu.employee_id%type,
        nume emp_pnu.first_name%type,
        salariu emp_pnu.salary%type,
        cod_dep emp_pnu.department_id%type
    );
    v_info_ang date_angajat;
BEGIN
    DELETE FROM EMP_PNU WHERE employee_id = 200
    RETURNING Employee_id, last_name, salary, department_id
    INTO v_info_ang;
    
    DBMS_OUTPUT.PUT_LINE('A fost stearsa linia continand valorile ' ||
     v_info_ang.cod ||' '||v_info_ang.nume||' ' ||v_info_ang.salariu ||' '
     || v_info_ang.cod_dep) ;
END;
/
ROLLBACK;

/*2. Folosind tipul declarat mai sus, să se adauge o linie în tabelul EMP_PNU prin intermediul unei
variabile de tip înregistrare initializate. Efectuati modificările necesare asupra tipului de date, astfel
încât această inserare să fie posibilă. La initializarea unei variabile de tip record, tineti cont de
constrângerile NOT NULL definite asupra tabelului EMP_PNU.
*/

DECLARE
    TYPE info_ang_pnu IS RECORD (
         cod NUMBER(4):=500,
         nume VARCHAR2(20):='abc',
         prenume VARCHAR2(20):='john',
         email emp_pnu.email%TYPE:='abc@mail',
         telefon emp_pnu.phone_number%type,
         data emp_pnu.hire_date%TYPE:=SYSDATE,
         job emp_pnu.job_id%TYPE:='SA_REP',
         salariu NUMBER(8, 2):=1000,
         comision emp_pnu.commission_pct%TYPE,
         manager emp_pnu.manager_id%TYPE,
         cod_dep NUMBER(4):=30
         );
    v_info_ang info_ang_pnu;
BEGIN
    INSERT INTO EMP_PNU VALUES v_info_ang;
    DBMS_OUTPUT.PUT_LINE('A fost stearsa linia continand valorile ' ||
     v_info_ang.cod ||' '||v_info_ang.nume||' ' ||v_info_ang.salariu ||' '
     || v_info_ang.cod_dep) ;
    
    v_info_ang.nume := 'Smith'; 
    
    UPDATE EMP_PNU 
    SET ROW = v_info_ang
    where employee_id = v_info_ang.cod;
    DBMS_OUTPUT.PUT_LINE('A fost stearsa linia continand valorile ' ||
     v_info_ang.cod ||' '||v_info_ang.nume||' ' ||v_info_ang.salariu ||' '
     || v_info_ang.cod_dep) ;
END;
/
ROLLBACK;

-- II. Index by table

/* 3. Să se definească un tablou indexat PL/SQL având elemente de tipul NUMBER. Să se introducă
20 de elemente în acest tablou. Să se afiúeze, apoi să se úteargă tabloul utilizând diverse metode.
*/
DECLARE
    TYPE map is TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
    v_map map;
    i NUMBER := 0;
BEGIN
    WHILE i < 20 LOOP
        v_map(i) := i;
        i:= i+ 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Numar elemente: ' || v_map.COUNT);
    FOR j IN 0..19 LOOP
        DBMS_OUTPUT.PUT_LINE(j);
    END LOOP;
    
    i:=0;
    LOOP
        IF v_map.COUNT <> 0 THEN 
            v_map.DELETE(i);
            i := i + 1;
        ELSE EXIT;
        END IF;
    END LOOP;
      DBMS_OUTPUT.PUT_LINE('Numar elemente: ' || v_map.COUNT);
END;
/

/* 4. Să se definească un tablou de înregistrări având tipul celor din tabelul dept_pnu. Să se iniĠializeze
un element al tabloului úi să se introducă în tabelul dept_pnu. Să se úteargă elementele tabloului.
*/

DECLARE
    TYPE map_departamente IS TABLE OF DEP_PNU%ROWTYPE
    INDEX BY BINARY_INTEGER;
    v_map_dep map_departamente;
BEGIN
    v_map_dep(0).department_id := 500;
    v_map_dep(0).department_name := 'Test'; 
    v_map_dep(0).manager_id := null;
    v_map_dep(0).location_id := null;
    INSERT INTO DEP_PNU VALUES v_map_dep(0);
    v_map_dep.DELETE(0);
END;
/




















