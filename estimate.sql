SET SERVEROUTPUT ON
prompt expected disk read can be taken from sqlhist
DECLARE
    v_sqlid           VARCHAR2(13);
    v_disk_reads1     NUMBER;
    v_disk_reads2     NUMBER;
    v_diff            NUMBER;
    v_total_expected  NUMBER;
    v_estimated_time  NUMBER;
BEGIN
    -- Prompt for sql_id
    v_sqlid := '&sql_id';

    -- First measurement
    SELECT NVL(SUM(DISK_READS), 0)
      INTO v_disk_reads1
      FROM gv$sql
     WHERE sql_id = v_sqlid;

    -- Wait for 30 seconds
    DBMS_LOCK.SLEEP(30);

    -- Second measurement
    SELECT NVL(SUM(DISK_READS), 0)
      INTO v_disk_reads2
      FROM gv$sql
     WHERE sql_id = v_sqlid;

    -- Calculate disk reads in 30 seconds
    v_diff := v_disk_reads2 - v_disk_reads1;
    DBMS_OUTPUT.PUT_LINE('Disk Reads in 30 seconds: ' || v_diff);

    -- Ask user for expected total disk reads
    v_total_expected := &total_disk_reads_expected;

    -- Estimate total time (in seconds)
    IF v_diff > 0 THEN
    -- Calculate remaining disk reads
    v_estimated_time := ((v_total_expected - v_disk_reads2) / v_diff) * 30;
    
    DBMS_OUTPUT.PUT_LINE('Already completed: ' || v_disk_reads2 || ' disk reads');
    DBMS_OUTPUT.PUT_LINE('Remaining: ' || (v_total_expected - v_disk_reads2) || ' disk reads');
    DBMS_OUTPUT.PUT_LINE('Estimated time to complete (seconds): ' || ROUND(v_estimated_time, 2));
    DBMS_OUTPUT.PUT_LINE('Estimated time to complete (minutes): ' || ROUND(v_estimated_time/60, 2));
	ELSE
    DBMS_OUTPUT.PUT_LINE('No disk reads detected in 30 seconds. Unable to estimate.');
	END IF;
END;
/
