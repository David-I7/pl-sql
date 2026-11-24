SET SERVEROUTPUT ON
SET SERVEROUTPUT OFF

/* 1. Să se actualizeze liniile tabelului emp_pnu, mărind cu 10% valoarea comisionului pentru salariatii
având salariul mai mic decât o valoare introdusă de utilizator. Să se afiseze dacă au fost actualizate
linii sau nu (SQL%FOUND), iar în caz afirmativ să se afiúeze numărul de linii afectate
(SQL%ROWCOUNT). Ce fel de cursor folosim?
*/

ACCEPT g_salariu_tinta NUMBER PROMPT 'Introdu salariul tinta:'

DECLARE
    cursor v_emp_cursor IS 
      SELECT * FROM emp_pnu WHERE salary <= &g_salariu_tinta
      FOR UPDATE;
    v_emp emp_pnu%ROWTYPE;
BEGIN
    OPEN v_emp_cursor;
    
    LOOP
        FETCH v_emp_cursor INTO v_emp;
        
        EXIT WHEN v_emp_cursor%NOTFOUND;
    
        UPDATE emp_pnu set salary = salary * 1.1
        WHERE CURRENT OF v_emp_cursor;
    END LOOP;
    
    IF v_emp_cursor%ROWCOUNT > 0 THEN
        dbms_output.put_line('S-au actualizat ' || v_emp_cursor%ROWCOUNT || ' inregistrari.' );
    ELSE dbms_output.put_line('Nu a fost actualizata nicio inregistrare.' );
    END IF;
    
    CLOSE v_emp_cursor;
END;
/

DECLARE
    cursor v_emp_cursor(v_salariu_tinta NUMBER) IS 
      SELECT * FROM emp_pnu WHERE salary <= v_salariu_tinta;
    v_emp emp_pnu%ROWTYPE;
BEGIN
    OPEN v_emp_cursor(3000);
    
    LOOP
        FETCH v_emp_cursor INTO v_emp;
        
        EXIT WHEN v_emp_cursor%NOTFOUND;
    
        UPDATE emp_pnu set salary = salary * 1.1
        WHERE employee_id = v_emp.employee_id;
    END LOOP;
    
    IF v_emp_cursor%ROWCOUNT > 0 THEN
        dbms_output.put_line('S-au actualizat ' || v_emp_cursor%ROWCOUNT || ' inregistrari.' );
    ELSE dbms_output.put_line('Nu a fost actualizata nicio inregistrare.' );
    END IF;
    
    CLOSE v_emp_cursor;
END;
/

DECLARE
    v_salariu_tinta NUMBER := 3000;
    v_nr_actualizari NUMBER := 0;
BEGIN
    FOR emp in (select * from emp_pnu where salary <= v_salariu_tinta) LOOP
        UPDATE emp_pnu set salary = salary * 1.1 where
        employee_id = emp.employee_id;
        v_nr_actualizari := v_nr_actualizari + SQL%ROWCOUNT;
    END LOOP;
    
    IF v_nr_actualizari > 0 THEN
        dbms_output.put_line('S-au actualizat ' || v_nr_actualizari || ' inregistrari.' );
    ELSE dbms_output.put_line('Nu a fost actualizata nicio inregistrare.' );
    END IF;
END;
/

/* 2. Să se creeze un tabel DEP_EMP_PNU având câmpurile cod_dep si cod_ang. Să se introducă
într-o variabilă de tip tablou imbricat codurile departamentelor (în care există angajati), iar apoi, prin
intermediul unei comenzi FORALL să se insereze aceste coduri si codurile angajatilor corespunzători
în tabelul DEP_EMP_PNU. Pentru fiecare departamentm să se afiúeze câci angajati au fost introdusi.
*/

CREATE TABLE DEP_EMP_PNU(
    cod_dep NUMBER(4) not null,
    cod_ang Number(6) not null
);

DECLARE
 TYPE t_dep IS TABLE OF NUMBER;
 V_dep t_dep;
BEGIN
    SELECT distinct department_id BULK COLLECT INTO v_dep FROM departments d join employees e on e.department_id = d.department_id;
    FORALL j IN 1..v_dep.COUNT
        INSERT INTO dep_emp_pnu
        SELECT department_id,employee_id
        FROM emp_pnu
        WHERE department_id_id = v_dep(j);
    FOR j IN 1..v_dep.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE ('Pentru departamentul avand codul ' ||
        v_dep(j) || ' au fost inserate ' ||
        SQL%BULK_ROWCOUNT(j)
        || 'inregistrari (angajati)');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('Numarul total de inregistrari
    inserate este '||SQL%ROWCOUNT);
End;
/

/* 3. Să se obtină câte o linie de forma '<nume> are salariul anual <salariu annual>' pentru fiecare
angajat din departamentul 50. Se cer 4 solutii (WHILE, LOOP, FOR specific cursoarelor cu varianta
de scriere a cursorului în interiorul său).
*/

DECLARE
    CURSOR emp_cursor IS 
        SELECT * FROM employees where department_id = 50;
    v_emp employees%ROWTYPE;
BEGIN 
    OPEN emp_cursor;
    
    FETCH emp_cursor INTO v_emp;
    WHILE (emp_cursor%FOUND) LOOP
        dbms_output.put_line(v_emp.last_name || ' ' || v_emp.first_name || ' are salariul anual de ' || v_emp.salary * 12);
        FETCH emp_cursor INTO v_emp;
    END LOOP;
    
    CLOSE emp_cursor;
END;
/

DECLARE
    CURSOR emp_cursor IS 
        SELECT last_name || ' ' || first_name full_name, salary * 12 sal_anual FROM employees where department_id = 50;
    v_emp emp_cursor%ROWTYPE;
BEGIN 
    OPEN emp_cursor;
    
    LOOP
        FETCH emp_cursor INTO v_emp;
        
        EXIT WHEN emp_cursor%NOTFOUND;
        
        dbms_output.put_line(v_emp.full_name || ' are salariul anual de ' || v_emp.sal_anual);
    END LOOP;
    
    CLOSE emp_cursor;
END;
/

DECLARE
    CURSOR emp_cursor IS 
        SELECT last_name || ' ' || first_name full_name, salary * 12 sal_anual FROM employees where department_id = 50;
BEGIN 
    FOR v_emp in emp_cursor LOOP
        dbms_output.put_line(v_emp.full_name || ' are salariul anual de ' || v_emp.sal_anual);
    END LOOP;
END;
/

DECLARE
    v_emp employees%ROWTYPE;
BEGIN     
    FOR v_emp in (SELECT * FROM employees where department_id = 50) LOOP
        dbms_output.put_line(v_emp.last_name || ' ' || v_emp.first_name || ' are salariul anual de ' || v_emp.salary * 12);
    END LOOP;
END;
/

/* 4. Sa se afiseze salariatii care au salariul mai mic de 7000$, in urmatoarea forma:
 -Salariatul <nume> castiga <salariu>-
*/

DECLARE
    CURSOR c_salariati IS
        SELECT last_name || ' ' || first_name full_name, salary  FROM EMPLOYEES 
        WHERE salary < 7000;
BEGIN
    FOR v_emp IN c_salariati LOOP
        dbms_output.put_line('Salariatul ' || v_emp.full_name || ' castiga ' || v_emp.salary);
    END LOOP;
END;
/

/* 5. Creati un bloc PL/SQL care determină cele mai mari n salarii, urmând pasii descrisi în continuare:
a) creati un tabel top_salarii_pnu, având o coloană salary.
b) Numărul n (al celor mai bine plătiti salariati) se va introduce de către utilizator (se va folosi
comanda SQL*Plus ACCEPT si o varianilă de substitutie p_num).
c) În sectiunea declarativă a blocului PL/SQL se vor declara 2 variabile: v_num de tip NUMBER
(corespunzătoare lui p_num) si v_sal de tipul coloanei salary. Se va declara un cursor
emp_cursor pentru regăsirea salariilor în ordine descrescătoare (se presupune că nu avem
valori duplicate).
d) Se vor introduce cele mai mari mai bine plătiti n angajati în tabelul top_salarii_pnu;
e) Afisati continutul tabelului top_salarii_pnu.
f) Testati cazuri speciale, de genul n = 0 sau n mai mare decât numărul de angajati. Se vor
elimina înregistrările din tabelul top_salarii_pnu după fiecare test.
*/

CREATE TABLE top_salarii_pnu(
    salary NUMBER
);

ACCEPT p_num NUMBER PROMPT 'Introdu numarul celor mai bine plătiti salariati:'

DECLARE
    v_num NUMBER := &p_num;
    v_sal employees.salary%type;
    CURSOR emp_cursor IS
        SELECT distinct salary from employees order by salary desc;
BEGIN
    OPEN emp_cursor;
    
    WHILE (v_num > 0) LOOP
        FETCH emp_cursor INTO v_sal;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        INSERT INTO top_salarii_pnu values (v_sal);
        v_num := v_num -1;
    END LOOP;
    
    CLOSE emp_cursor;
    
    dbms_output.put_line('Top ' || (&p_num - v_num) || ' salarii:');
    FOR v_linie in (select * from top_salarii_pnu) LOOP
        dbms_output.put_line(v_linie.salary);
    END LOOP;
END;
/

/* 6. Să se declare un cursor cu un parametru de tipul codului angajatului, care regăseste numele si
salariul angajatilor având codul transmis ca parametru sau ale numele si salariile tuturor angajatilor
daca valoarea parametrului este null. Să se declare o variabilă v_nume de tipul unei linii a cursorului.
Să se declare două tablouri de nume (v_tab_nume), respectiv salarii (v_tab_sal). Să se parcurgă
liniile cursorului în două moduri: regăsindu-le în v_nume sau în cele două variabile de tip tablou.
*/


DECLARE
    CURSOR emp_cursor(v_cod_ang employees.employee_id%type) IS
        SELECT last_name, salary from employees
        where v_cod_ang is NULL
        OR employee_id = v_cod_ang;
    v_emp emp_cursor%ROWTYPE;
    
    TYPE tab_nume IS TABLE OF employees.last_name%TYPE;
    TYPE tab_sal IS TABLE OF employees.last_name%TYPE;   
    v_tab_nume tab_nume;
    v_tab_sal tab_sal;
BEGIN
    dbms_output.put_line('Varianta 1: ');
    OPEN emp_cursor(null);
    LOOP
        FETCH emp_cursor INTO v_emp;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        dbms_output.put_line(v_emp.last_name || ' are salariul ' || v_emp.salary);
    END LOOP;
    CLOSE emp_cursor;
    
    dbms_output.put_line('Varianta 2: ');
    OPEN emp_cursor(null);
    FETCH emp_cursor bulk collect into v_tab_nume,v_tab_sal;
    FOR i in v_tab_nume.FIRST..v_tab_nume.LAST LOOP
        dbms_output.put_line(v_tab_nume(i) || ' are salariul ' || v_tab_sal(i));
    END LOOP;
    CLOSE emp_cursor;
END;
/

/* 7.Rezolva exercitiul 6 folosind while
*/

DECLARE
    CURSOR emp_cursor(v_cod_ang employees.employee_id%type) IS
        SELECT last_name, salary from employees
        where v_cod_ang is NULL
        OR employee_id = v_cod_ang;
    v_emp emp_cursor%ROWTYPE;
    
    TYPE tab_nume IS TABLE OF employees.last_name%TYPE;
    TYPE tab_sal IS TABLE OF employees.last_name%TYPE;   
    v_tab_nume tab_nume;
    v_tab_sal tab_sal;
    i NUMBER := 0;
BEGIN
    dbms_output.put_line('Varianta 1: ');
    OPEN emp_cursor(null);
    FETCH emp_cursor INTO v_emp;
    WHILE (emp_cursor%FOUND) LOOP
        dbms_output.put_line(v_emp.last_name || ' are salariul ' || v_emp.salary);
        FETCH emp_cursor INTO v_emp;
    END LOOP;
    CLOSE emp_cursor;
    
    dbms_output.put_line('Varianta 2: ');
    OPEN emp_cursor(null);
    FETCH emp_cursor bulk collect into v_tab_nume,v_tab_sal;
    i:= v_tab_nume.FIRST;
    WHILE (i < v_tab_nume.LAST) LOOP
        dbms_output.put_line(v_tab_nume(i) || ' are salariul ' || v_tab_sal(i));
        i:= v_tab_nume.NEXT(i);
    END LOOP;
    CLOSE emp_cursor;
END;
/

/* 8. Rezolva exercitiul 6 folosind FOR
*/

DECLARE
    CURSOR emp_cursor(v_cod_ang employees.employee_id%type) IS
        SELECT last_name, salary from employees
        where v_cod_ang is NULL
        OR employee_id = v_cod_ang;    
BEGIN
    FOR v_emp in emp_cursor LOOP
        dbms_output.put_line(v_emp.last_name || ' are salariul ' || v_emp.salary);
    END LOOP;
END;
/

/* 9. Utilizând un cursor parametrizat să se obtină codurile angajatilor din fiecare departament si pentru
fiecare job. Rezultatele să fie inserate în tabelul mesaje, sub forma câte unui sir de caractere obtinut
prin concatenarea valorilor celor 3 coloane.
*/

CREATE TABLE MESAJE(
    mesaj VARCHAR2(255)
);

DECLARE
    v_cod_dep departments.department_id%TYPE;
    v_cod_job departments.job_id%TYPE;
    v_mesaj VARCHAR2(75);
    CURSOR dep_job IS
        SELECT department_id, job_id
        FROM emp_pnu;
    CURSOR emp_cursor (v_id_dep NUMBER,v_id_job VARCHAR2) IS
        SELECT employee_id || department_id || job_id
        FROM emp_pnu
        WHERE department_id = v_id_dep
        AND job_id = v_id_job;
BEGIN
    OPEN dep_job;
    LOOP
        FETCH dep_job INTO v_cod_dep,v_cod_job;
        EXIT WHEN dep_job%NOTFOUND;
        IF emp_cursor%ISOPEN THEN
            CLOSE emp_cursor;
        END IF;
        OPEN emp_cursor (v_cod_dep, v_cod_job);
        LOOP
            FETCH emp_cursor INTO v_mesaj;
            EXIT WHEN emp_cursor%NOTFOUND;
            INSERT INTO mesaje (rezultat)
            VALUES (v_mesaj);
        END LOOP;
        CLOSE emp_cursor;
    END LOOP;
    CLOSE dep_job;
    COMMIT;
END;
/

/* 10. Să se dubleze valoarea salariilor angajatilor înainte de 1 ianuarie 1995, care nu câstigă comision
*/

DECLARE 
    CURSOR emp_cursor IS 
        SELECT employee_id, salary 
        FROM EMP_PNU
        WHERE hire_date < TO_DATE('1995-01-01', 'YYYY-MM-DD') and commission_pct is null
        FOR UPDATE;
BEGIN
    FOR v_emp in emp_cursor LOOP
        UPDATE emp_pnu set salary = v_emp.salary * 2
        WHERE CURRENT OF emp_cursor;
    END LOOP;
    ROLLBACK; -- Elibereaza lacatele fara sa salveze datele
END;
/

select * from emp_pnu where hire_date < TO_DATE('1995-01-01', 'YYYY-MM-DD') and commission_pct is null;

/* 11. Să se declare un cursor cu un parametru de tipul coloanei location_id, care determină
departamentele din locatia respectivă si blochează liniile pe perioada prelucrării acestora. Să se
deschidă cursorul folosind o variabilă de substitutie pentru furnizarea parametrului. Să se actualizeze
tabelul dep_pnu, dând valoarea 100 locatiei corespunzătoare liniei curente a cursorului.
*/

DEFINE g_location_id = 1700

DECLARE
    CURSOR dep_in_loc_cursor(v_loc_id dep_pnu.location_id%type) IS
        SELECT department_id FROM dep_pnu 
        WHERE location_id = v_loc_id
        FOR UPDATE;
BEGIN
    FOR dep in dep_in_loc_cursor(&g_location_id) LOOP
        UPDATE DEP_PNU SET location_id = 100
        WHERE CURRENT OF dep_in_loc_cursor;
    END LOOP;
    ROLLBACK; -- eliberareaza resursele
END;
/

/* 12. Să se declare un cursor dinamic care întoarce linii de tipul celor din tabelul emp_pnu. Să se
citească o optiune de la utilizator, care va putea lua valorile 1, 2 sau 3. Pentru optiunea 1 deschideti
cursorul astfel încât să regăsească toate informatiile din tabelul EMP_pnu, pentru optiunea 2,
cursorul va regăsi doar angajatii având salariul cuprins între 10000 si 20000, iar pentru opyiunea 3 se
vor regăsi salariatii angajati în anul 1990.
*/

ACCEPT g_op NUMBER PROMPT 'Introdu optiunea (1,2 sau 3):'

DECLARE 
     TYPE emp_cursor IS REF CURSOR RETURN emp_pnu%ROWTYPE;
     v_emp_cursor emp_cursor;
     v_emp emp_pnu%ROWTYPE;
BEGIN
    IF &g_op = 1 THEN
        OPEN v_emp_cursor FOR
            SELECT * FROM EMP_PNU;
    ELSIF &g_op = 2 THEN
        OPEN v_emp_cursor FOR
            SELECT * FROM EMP_PNU WHERE salary between 10000 and 20000;
    ELSIF &g_op = 3 THEN
        OPEN v_emp_cursor FOR
            SELECT * FROM EMP_PNU WHERE EXTRACT(YEAR FROM hire_date) = 1990;
    ELSE dbms_output.put_line('Optiunea selectate este invalida');
    END IF;
    
    IF v_emp_cursor%ISOPEN THEN
        LOOP
            FETCH v_emp_cursor INTO v_emp;
            EXIT WHEN v_emp_cursor%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE(
                v_emp.last_name || ' ' || v_emp.employee_id
            );
        END LOOP;

        CLOSE v_emp_cursor;
    END IF;
END;
/

/* 13. Să se citească o valoare n de la tastatura. Prin intermediul unui cursor deschis cu ajutorul unui sir
dinamic să se regăsească angajatii având salariul mai mare decât n. Pentru fiecare linie regăsită de
cursor, dacă angajatul are comision, să se afiseze numele său si salariul.
*/

ACCEPT g_n NUMBER PROMPT 'Introdu valoarea pentru n:'

DECLARE
    v_n NUMBER := &g_n;
    TYPE emp_with_salary_greater_than_n IS REF CURSOR RETURN emp_pnu%rowtype;
    v_cursor emp_with_salary_greater_than_n;
    v_emp emp_pnu%rowtype;
BEGIN
    OPEN v_cursor for
        SELECT * FROM EMP_PNU 
        WHERE salary > v_n;
    
    IF v_cursor%ISOPEN then
        FETCH v_cursor into v_emp;
        WHILE (v_cursor%FOUND) LOOP
            IF v_emp.commission_pct is not null then
                DBMS_OUTPUT.PUT_LINE(
                   'Nume: ' || v_emp.last_name || ', Salariu:' || v_emp.salary
                );
            END IF;
            FETCH v_cursor into v_emp;
        END LOOP;
        
        CLOSE v_cursor;
    END IF;  
END;
/

/* 14. Să se listeze numele regiunilor si pentru fiecare regiune să se afiseze numele tărilor. Se cer 2
metode de rezolvare (secvential si cu expresii cursor).
*/

BEGIN
 FOR c_regiune IN (SELECT region_id, region_name FROM regions) 
 LOOP
     DBMS_OUTPUT.PUT_LINE (c_regiune.region_name);
     FOR c_tara IN (SELECT country_id, country_name
                     FROM countries
                     WHERE region_id = c_regiune.region_id) 
     LOOP
         DBMS_OUTPUT.PUT_LINE (c_tara.country_name);
     END LOOP;
 END LOOP;
END;

DECLARE
    CURSOR c_regiune IS 
        SELECT region_name,
        CURSOR (SELECT country_name
                FROM countries c
                WHERE c.region_id = r.region_id)
        FROM regions r;
    v_regiune regions.region_name%TYPE;
    v_tara SYS.REFCURSOR;
    TYPE tara_nume IS TABLE OF countries.country_name%TYPE
    INDEX BY BINARY_INTEGER;
    v_nume_tara tara_nume;
BEGIN
    OPEN c_regiune;
    LOOP
        FETCH c_regiune INTO v_regiune, v_tara;
        EXIT WHEN c_regiune%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE (v_regiune);
        FETCH v_tara BULK COLLECT INTO v_nume_tara;
        FOR ind IN v_nume_tara.FIRST..v_nume_tara.LAST
        LOOP
            DBMS_OUTPUT.PUT_LINE (v_nume_tara (ind));
        END LOOP;
    END LOOP;
    CLOSE c_regiune;
END;
/
