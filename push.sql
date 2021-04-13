  procedure push
  (
  out_resp     out varchar2
  )
  as
  
    req utl_http.req;
    resp utl_http.resp;
    vURL varchar2(2000);
    request_text varchar2(1000);

    pagelob CLOB;
    buf VARCHAR2(32767);
    vERRM   varchar2(2000);
    
    vINST   varchar2(100);
  
  BEGIN
    begin
      SELECT SYS_CONTEXT('USERENV','SERVER_HOST')
      into   vINST
      FROM   dual;
    end;
    
    
    /* Формируем URL  */
    /* Gateway addr */
    vURL := 'http://srv-prometheus-01:9091/metrics/';
    
    /* url add + label_job */
    vURL := vURL||'label_job'||'/';
    vURL := vURL||'job_name'||'/';
    
    /* url add + label_env */
    vURL := vURL||'label_env'||'/';
    vURL := vURL||'env_name'||'/';

    /* url add + label_instance */
    vURL := vURL||'label_instance'||'/';
    vURL := vURL||'instance_name'||'_'||vINST||'/';
    
    /* url add + label_entity */
    vURL := vURL||'label_entity'||'/';
    vURL := vURL||'instance_name'||'/';    

    /* url add + label_action */
    vURL := vURL||'label_action'||'/';
    vURL := vURL||'action_name';
    
    
    dbms_output.put_line(vURL);    
    
    
   -- enable http exception
    utl_http.set_response_error_check (true);
    utl_http.set_detailed_excp_support (true);
    

    req := utl_http.begin_request (vURL, 'POST', 'HTTP/1.1');


    request_text := in_rec.m_metrics||' '||in_rec.new_val||chr(10);


    utl_http.set_header(req, 'User-Agent', 'Oracle UTL_HTTP');
    utl_http.set_header(req, 'content-type', 'text/plain');
    utl_http.set_header(req, 'content-length', length(request_text));


    utl_http.write_text(req, request_text);

    begin

    resp := utl_http.get_response (req);
    exception
      when others then vERRM := 'ERROR in REQUEST '||sqlerrm;
                       out_resp := vERRM;
    end;
    
    out_resp := resp.status_code||' '||resp.reason_phrase;
    
/*    if resp.status_code <> 200 and resp.reason_phrase <> 'OK' then

      BEGIN
         LOOP
            UTL_HTTP.read_text(resp, buf);
            DBMS_LOB.writeappend(pagelob, LENGTH(buf), buf);
            dbms_output.put_line(buf);
         END LOOP;
         EXCEPTION
           WHEN UTL_HTTP.end_of_body
             THEN
               dbms_output.put_line('UTL_HTTP.end_of_body');
      END;
    end if;*/


  END;
