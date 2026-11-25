-- Proceduri locale
/* 1. Să se declare o procedură locală într-un bloc PL/SQL anonim prin care să se introducă în
tabelul DEP_pnu o nouă înregistrare precizând, prin intermediul parametrilor, valori pentru toate
câmpurile. Invocati procedura în cadrul blocului. Interogati tabelul DEP_pnu si apoi anulati
modificările (ROLLBACK).
*/

DECLARE
    PROCEDURE add_dep (
        dep_id dep_pnu.department_id%type,
        dep_name dep_pnu.department_name%type,
        man_id dep_pnu.manager_id%type:=NULL,
        loc_id dep_pnu.location_id%type:=NULL
    ) AS
    BEGIN 
        INSERT INTO DEP_PNU VALUES (dep_id,dep_name,man_id,loc_id);
    END;
BEGIN
    add_dep(1000,'Test 1',NULL,NULL);
    add_dep(dep_name=>'Test 2',dep_id=>1001,man_id=>NULL,loc_id=>NULL);
    add_dep(dep_name=>'Test 3',dep_id=>1002);
END;
/

select * from dep_pnu;
rollback;


/* 2. Să se declare o procedură locală care are parametrii următori:
- p_rezultat (parametru de tip IN OUT) de tipul coloanei last_name din tabelul employees;
- p_comision (parametru de tip OUT) de tipul coloanei commission_pct din employees, initializat
cu NULL;
- p_cod (parametru de tip IN) de tipul coloanei employee_id din employees, initializat cu NULL.
Dacă p_comision nu este NULL atunci în p_rezultat se va memora numele salariatului care are
salariul maxim printre salariatii având comisionul respectiv. În caz contrar, în p_rezultat se va
memora numele salariatului al cărui cod are valoarea dată la apelarea procedurii.
*/

SET SERVEROUTPUT ON

DECLARE
    v_rezultat employees.last_name%TYPE;
    PROCEDURE solution_2 (
        p_rezultat IN OUT employees.last_name%TYPE, 
        p_comision IN employees.commission_pct%TYPE := NULL,
        p_cod IN employees.employee_id%TYPE :=NULL
    ) AS
    BEGIN 
        IF p_comision IS NOT NULL THEN
          SELECT last_name into p_rezultat FROM employees where commission_pct = p_comision 
                  order by salary DESC 
                  FETCH FIRST 1 ROWS ONLY; 
          DBMS_OUTPUT.PUT_LINE('Numele salariatului care are comisionul '||p_comision||
                                ' este '||p_rezultat);
        ELSE 
            SELECT last_name INTO p_rezultat FROM EMPLOYEES WHERE employee_id = p_cod;
            DBMS_OUTPUT.PUT_LINE('numele salariatului avand codul '||p_cod||
                                 ' este '||p_rezultat);
        END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('Nu am gasit angajatul cu codul sau comisionul respectiv');
    END;
BEGIN
    solution_2 (v_rezultat,0.4);
    solution_2 (v_rezultat,p_cod=>205);
    solution_2 (v_rezultat);
END;
/


-- Proceduri stocate
/* 3. Să se creeze o procedură stocată fără parametri care afisează un mesaj “Programare PL/SQL”,
ziua de astăzi în formatul DD-MONTH-YYYY si ora curentă, precum si ziua de ieri în formatul DD-MON-YYYY
*/


CREATE OR REPLACE PROCEDURE sol_3 AS
BEGIN
    dbms_output.put_line('Programare PL/SQL');
    dbms_output.put_line('Azi: ' || to_char(CURRENT_TIMESTAMP, 'DD-MONTH-YYYY HH24'));
    dbms_output.put_line('Ieri: ' || to_char(CURRENT_TIMESTAMP - 1, 'DD-MON-YYYY'));
END;
/

BEGIN 
    sol_3;
END;
/

/* 4. Să se steargă procedura precedentă si să se re-creeze, astfel încât să accepte un parametru IN
de tip VARCHAR2, numit p_nume. Mesajul afisat de procedură va avea forma '<p_nume> invata
PL/SQL'. Invocati procedura cu numele utilizatorlui curent furnizat ca parametru.
*/

DROP PROCEDURE sol_3;

CREATE OR REPLACE PROCEDURE sol_3(p_nume VARCHAR) AS
BEGIN
    dbms_output.put_line(p_nume || ' invata PL/SQL');
    dbms_output.put_line('Azi: ' || to_char(CURRENT_TIMESTAMP, 'DD-MONTH-YYYY hh24:mi:ss'));
    dbms_output.put_line('Ieri: ' || to_char(CURRENT_TIMESTAMP - 1, 'DD-MON-YYYY'));
END;
/

EXECUTE sol_3(USER);

/* 5. a) Creati o copie JOBS_pnu a tabelului JOBS. Implementati constrângerea de cheie primară
         asupra lui JOBS_pnu.
      b) Creati o procedură ADD_JOB_pnu care inserează un nou job în tabelul JOBS_pnu.
         Procedura va avea 2 parametri IN p_id si p_title corespunzători codului si denumirii noului job.
*/

CREATE TABLE JOBS_PNU AS
SELECT * FROM JOBS;

ALTER TABLE JOBS_PNU ADD CONSTRAINT job_id PRIMARY KEY(job_id);

CREATE OR REPLACE PROCEDURE add_job (p_id jobs_pnu.job_id%type, p_title jobs_pnu.job_title%type) 
AS
    e_null_not_allowed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_null_not_allowed, -1400);
BEGIN
    INSERT INTO jobs_pnu values (p_id,p_title,NULL,NULL);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Job ID already exists!');
        WHEN e_null_not_allowed THEN
            DBMS_OUTPUT.PUT_LINE('p_id and p_title cannot be null');
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

EXECUTE add_job(1010100101,'TEST');


/* 6. Creati o procedură stocată numită UPD_JOB_pnu pentru modificarea unui job existent în
      tabelul JOBS_pnu. Procedura va avea ca parametri codul job-ului si noua sa denumire (parametri
      IN). Se va trata cazul în care nu are loc nici o actualizare
*/

CREATE PROCEDURE upd_job_pnu (p_id jobs_pnu.job_id%type, p_new_title jobs_pnu.job_title%type)
AS
BEGIN
    UPDATE jobs_pnu set job_title = p_new_title WHERE  job_id = p_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Job-ul cu id-ul ' || p_id || ' nu exista');
    END IF;
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1400 THEN
                DBMS_OUTPUT.PUT_LINE('p_id si p_new_title nu pot fi nule');
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

EXECUTE add_job('IT_DBA', 'Database Administrator');
EXECUTE UPD_JOB_pnu('IT_DBA', 'Data Administrator');
SELECT * FROM jobs_pnu
 WHERE UPPER(job_id) = 'IT_DBA';
EXECUTE UPD_JOB('IT_WEB', 'Web master');


/* 7. Creati o procedură stocată numită DEL_JOB_pnu care sterge un job din tabelul JOBS_pnu.
Procedura va avea ca parametru (IN) codul job-ului. Includeti o exceptie corespunzătoare situatiei
în care nici un job nu este sters.
*/

CREATE OR REPLACE PROCEDURE del_job_pnu (p_id jobs_pnu.job_id%type)
AS
BEGIN
    DELETE FROM jobs_pnu WHERE job_id = p_id;
    
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20202, 'Job-ul cu id-ul ' || p_id || ' nu exista');
    ELSE dbms_output.put_line('Job-ul a fost sters cu succes');
    END IF;
END;

EXECUTE del_job_pnu('IT_DBA');
EXECUTE del_job_pnu('JOB_INVALID');

/* 8. a) Să se creeze o procedură stocată care calculează salariul mediu al angajatilor, returnându-l
         prin intermediul unui parametru de tip OUT.
      b) Să se apeleze procedura regăsind valoarea medie a salariilor într-o variabilă gazdă. Afisati
         valoarea variabilei.
*/

CREATE OR REPLACE PROCEDURE avg_salary (p_avg_salary OUT NUMBER)
AS
BEGIN
    SELECT AVG(salary) INTO p_avg_salary
    FROM employees;    
END;

VARIABLE g_avg_salary NUMBER
EXECUTE avg_salary(:g_avg_salary);
PRINT g_avg_salary

/* 9.a) Să se creeze o procedură stocată care primeste printr-un parametru salariul unui angajat si
          returnează prin intermediul aceluiasi parametru salariul actualizat astfel: dacă salariul este mai mic
          decât 3000, valoarea lui creste cu 20%, dacă este cuprins între 3000 si 7000 valoarea lui creste cu
          15%, dacă este mai mare decât 7000 va fi mărit cu 10%, iar dacă este null va lua valoarea 1000.
     b) Să se declare o variabilă gazdă g_sal (VARIABLE). Să se scrie un bloc anonim PL/SQL prin
            care se va atribui variabilei g_sal valoarea unei variabile de substitutie citite de la tastatură
            (ACCEPT). Să se apeleze procedura pentru această valoare si să se afiseze valoarea returnată.
*/

CREATE OR REPLACE PROCEDURE update_salary (p_salary IN OUT employees.salary%type)
AS
BEGIN
    IF p_salary IS NULL THEN
        p_salary := 1000;
    ElSIF p_salary < 3000 THEN
         p_salary := p_salary * 1.2;
    ElSIF p_salary between 3000 and 7000 THEN
         p_salary := p_salary * 1.5;
    ELSE p_salary := p_salary * 1.1;
    END IF;
END;

VARIABLE g_sal NUMBER
ACCEPT g_input_sal NUMBER PROMPT 'Introdu salariul:'

BEGIN
    :g_sal := &g_input_sal;
    update_salary(:g_sal);
END;
/

PRINT g_sal;

-- Functii Locale

/* 10. Să se creeze o procedură stocată care pentru un anumit cod de departament (dat ca
       parametru) calculează prin intermediul unor functii locale numărul de salariati care lucrează în el,
       suma salariilor si numărul managerilor salariatilor care lucrează în departamentul respectiv.
*/

CREATE OR REPLACE PROCEDURE sol_10(p_dep_id departments.department_id%type)
AS
    FUNCTION numar_salariati 
    RETURN NUMBER
    AS
        v_rezultat NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_rezultat from employees where department_id = p_dep_id;
        RETURN v_rezultat;
    END;
    FUNCTION suma_salarii
    RETURN NUMBER
    AS
        v_rezultat NUMBER;
    BEGIN
        SELECT SUM(salary) INTO v_rezultat from employees where department_id = p_dep_id;
        RETURN v_rezultat;
    END;
    FUNCTION numar_manageri
    RETURN NUMBER
    AS
        v_rezultat NUMBER;
    BEGIN
        SELECT COUNT(distinct manager_id) INTO v_rezultat from employees where department_id = p_dep_id;
        RETURN v_rezultat;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Numar salariati: ' || numar_salariati);
    DBMS_OUTPUT.PUT_LINE('Suma salarii: ' || suma_salarii);
    DBMS_OUTPUT.PUT_LINE('Numar manageri: ' || numar_manageri);
END;

EXECUTE sol_10(90);


/* 11. Să se creeze două functii (locale) supraîncărcate (overload) care să calculeze media salariilor
       astfel:
       - prima functie va avea ca argument codul departamentului, adică funcTia calculează media
         salariilor din departamentul specificat;
       - a doua functie va avea două argumente, unul reprezentând codul departamentului, iar
         celălalt reprezentând job-ul, adică functia va calcula media salariilor dintr-un anumit
         departament si care apartin unui job specificat.
*/

SET SERVEROUTPUT ON

DECLARE
    FUNCTION avg_salary (p_dep_id employees.department_id%type)
    RETURN NUMBER
    AS
        v_rezultat NUMBER;
    BEGIN
        SELECT AVG(salary) INTO v_rezultat FROM employees WHERE department_id = p_dep_id;
        RETURN v_rezultat;
    END;
    
    FUNCTION avg_salary (p_dep_id employees.department_id%type, p_job_id employees.job_id%type)
    RETURN NUMBER
    AS
        v_rezultat NUMBER;
    BEGIN
        SELECT AVG(salary) INTO v_rezultat FROM employees 
        WHERE department_id = p_dep_id AND job_id = p_job_id;
        RETURN v_rezultat;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Media salariilor din departamentul 80 este ' || avg_salary(80));
    DBMS_OUTPUT.PUT_LINE('Media salariilor reprezentantilor de vanzari din departamentul 80 este ' || avg_salary(80,'SA_REP'));
END;
/

-- Functii Stocate

/* 12. Să se creeze o functie stocată care determină numărul de salariati din employees angajati
       după 1995, într-un departament dat ca parametru. Să se apeleze această functie prin diferite
       modalităti:
       - printr-o variabilă de legătură;
       - folosind comanda CALL;
       - printr-o comandă SELECT;
       - într-un bloc PL/SQL.
*/

CREATE OR REPLACE FUNCTION nr_of_employees_after_1995(p_dep_id employees.department_id%type)
RETURN NUMBER
AS
    v_rezultat NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_rezultat FROM employees 
    WHERE department_id = p_dep_id AND EXTRACT(year from hire_date) > 1995;
    RETURN v_rezultat;
END;

VARIABLE g_rez NUMBER
EXECUTE :g_rez := nr_of_employees_after_1995(80);
PRINT g_rez

CALL nr_of_employees_after_1995(80) into :g_rez;
PRINT g_rez

SELECT nr_of_employees_after_1995(80) FROM DUAL;

BEGIN
    :g_rez := nr_of_employees_after_1995(80);
END;
/
PRINT g_rez

/* 13. a) Creati o functie numită VALID_DEPTID_pnu pentru validarea unui cod de departament
          specificat ca parametru. Functia va întoarce o valoare booleana (TRUE dacă departamentul
          există).
       b) Creati o procedură numită ADD_EMP_pnu care adaugă un angajat în tabelul EMP_pnu.
        Linia respectivă va fi adăugată în tabel doar dacă departamentul specificat este valid, altfel
        utilizatorul va primi un mesaj adecvat.
        - Procedura va avea următorii parametrii, cu valorile DEFAULT specificate între paranteze :
        first_name, last_name, email, job_id (SA_REP), manager_id (145), salary (1000), commission_pct
        (0), department_id (30).
         - Pentru codul angajatului se va utiliza o secventă EMP_SEQ_pnu, iar data angajării se
        consideră a fi TRUNC(SYSDATE).
       c) Testati procedura, adăugând un angajat pentru care se specifică numele, prenumele, codul
        departamentului = 15, iar restul parametrilor se lasă DEFAULT.
         Adăugati un angajat pentru care se specifică numele, prenumele, codul departamentului =80,
        iar restul parametrilor rămân la valorile DEFAULT.
         Adăugati un angajat precizând valori pentru toti parametrii procedurii.
*/

CREATE OR REPLACE FUNCTION VALID_DEPTID_pnu (p_dep_id departments.department_id%type)
RETURN BOOLEAN
AS
 v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM departments WHERE department_id = p_dep_id;
    RETURN v_count > 0;
END;

CREATE SEQUENCE EMP_PNU_SEQ
START WITH 1000
INCREMENT BY 1;

CREATE OR REPLACE FUNCTION ADD_EMP_pnu (
                first_name employees.first_name%type, 
                last_name employees.last_name%type, 
                email employees.email%type, 
                job_id employees.job_id%type := 'SA_REP', 
                manager_id employees.manager_id%type := 145, 
                salary employees.salary%type := 1000, 
                commission_pct employees.commission_pct%type := 0, 
                department_id employees.department_id%type := 30
            )
RETURN employees.employee_id%type
AS
    v_emp_id employees.employee_id%type;
BEGIN
    IF NOT valid_deptid_pnu(department_id) THEN
        DBMS_OUTPUT.PUT_LINE('Departamentul cu id-ul ' || department_id || ' nu exista');
        RETURN v_emp_id;
    END IF;
    INSERT INTO EMP_PNU values (emp_pnu_seq.NEXTVAL, first_name, last_name, email, null, trunc(SYSDATE), job_id,salary, commission_pct, manager_id, department_id)
    RETURNING employee_id INTO v_emp_id;
    RETURN V_EMP_ID;
END;

DECLARE
    v_emp_id employees.employee_id%type; 
BEGIN
    v_emp_id := ADD_EMP_pnu(
        'Max',
        'Verstappen',
        'max_verstappen@gmail.com',
        department_id => 15
    );

    DBMS_OUTPUT.PUT_LINE(v_emp_id);

    v_emp_id := ADD_EMP_pnu(
        'Max',
        'Verstappen',
        'max_verstappen@gmail.com',
        department_id => 80
    );

    DBMS_OUTPUT.PUT_LINE(v_emp_id);
END;

/* 14. Să se calculeze recursiv numărul de permutări ale unei multimi cu n elemente, unde n va fi
       transmis ca parametru.
*/

CREATE OR REPLACE FUNCTION factorial (p_n NUMBER)
RETURN NUMBER
AS
    v_res NUMBER;
BEGIN
    IF p_n = 1 OR p_n = 0 THEN
        RETURN 1;
    END IF;
    RETURN factorial(p_n - 1) * p_n;
END;

select factorial(5) from dual;

/* 15. Să se afiseze numele, job-ul si salariul angajatilor al căror salariu este mai mare decât media
salariilor din tabelul employees.
*/

CREATE OR REPLACE FUNCTION medie_pnu
 RETURN NUMBER AS
    medie NUMBER;
BEGIN
    SELECT AVG(salary)
    INTO medie
    FROM employees;
    RETURN medie;
END;
/
SELECT last_name, job_id, salary
FROM employees
WHERE salary >= medie_pnu;