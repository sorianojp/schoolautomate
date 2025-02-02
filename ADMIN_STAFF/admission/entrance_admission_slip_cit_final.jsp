<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,enrollment.CourseRequirement"	%>
<%
        WebInterface WI = new WebInterface(request);
		String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
		if(strSchCode == null)
			strSchCode = "";
		boolean bolIsWNU = strSchCode.startsWith("WNU");

    if (WI.fillTextValue("print_page").equals("1")){%>
  <jsp:forward page="./entrance_admission_slip_cit_final_print.jsp" />
  <%return;}
          //authenticate user access level
          int iAccessLevel = -1;
          java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

          if(svhAuth == null)
            iAccessLevel = -1; // user is logged out.
          else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
            iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
          else {
            iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ADMISSION MAINTENANCE-ENTRANCE EXAM/INTERVIEW"),"0"));
            if(iAccessLevel == 0) {
              iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ADMISSION MAINTENANCE"),"0"));
            }
			if(iAccessLevel == 0) 
	            iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ADMISSION MAINTENANCE-ADMISSION SLIP"),"0"));
          }

          if(iAccessLevel == -1)//for fatal error.
          {
            request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
            request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
            response.sendRedirect("../../../commfile/fatal_error.jsp");
            return;
          } else if(iAccessLevel == 0)//NOT AUTHORIZED.
          {
            response.sendRedirect("../../../commfile/unauthorized_page.jsp");
            return;
          }

          DBOperation dbOP = new DBOperation();
          String strErrMsg = null;
          String strTemp = null;
		  
		  //check if this is old student.. 
		  if(WI.fillTextValue("temp_id").length() > 0 && dbOP.mapUIDToUIndex(WI.fillTextValue("temp_id")) != null) {dbOP.cleanUP();
		  request.setAttribute("old_id", WI.fillTextValue("temp_id"));
		  %>
  				<jsp:forward page="./entrance_admission_slip_cit_final_print_old.jsp" />
		  	
		  <%return;}
		  
		  
          OfflineAdmission offlineAdd = new OfflineAdmission();
          CourseRequirement cRequirement = new CourseRequirement();
		  enrollment.ApplicationMgmt applMgmt = new enrollment.ApplicationMgmt();
		  
		  
          Vector vAdmissionReq = null;
          Vector vRetResult = null;
          Vector vCompliedRequirement = null;
          Vector vExamsPassed = null;
		  
		  ///only if there are any lacking mandatory basic information to be filled up.. 
		  String strLackingBasicInfo = null;
		  
		  
          String strTempID = WI.fillTextValue("temp_id");
          String strSYFrom = null;
          String strSYTo = null;
          String strSemester = null;
          String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
          String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
          String strPrintBy = WI.fillTextValue("print_by");

          if (strTempID.length() > 0 && !strPrintBy.equals("1")){
            //vRetResult = offlineAdd.createAdmissionSlipReq(dbOP,request,strTempID);
            vRetResult = offlineAdd.createAdmissionSlipReq(dbOP,strTempID);
            if (vRetResult == null)
              strErrMsg = offlineAdd.getErrMsg();
            if(vRetResult != null && vRetResult.size() > 0) {
              strSYFrom = (String)vRetResult.elementAt(0);
              strSYTo = (String)vRetResult.elementAt(1);
              strSemester = (String)vRetResult.elementAt(12);

              vAdmissionReq = cRequirement.getStudentPendingCompliedList(dbOP,(String)vRetResult.elementAt(16),
                  strSYFrom,strSYTo,strSemester,true,true,true);//get both pending and complied list

              if(vAdmissionReq == null && strErrMsg == null)
                strErrMsg = cRequirement.getErrMsg();
              else {
                vCompliedRequirement = (Vector)vAdmissionReq.elementAt(1);
              }
              vExamsPassed = offlineAdd.getExamResults(dbOP,request,strTempID);
            }
          } 
		  else if(strPrintBy.equals("1")){
            vRetResult = offlineAdd.getStudentNames(dbOP,request);
            if(vRetResult == null)
              strErrMsg = offlineAdd.getErrMsg();
          }	
		  
		  //check if all basic information already filled up.. 
		  if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(16) != null) {
			osaGuidance.StudentPersonalDataCIT SPRCIT = new osaGuidance.StudentPersonalDataCIT();
			
			//check if HSGrad.
			boolean bolIsHSGrad = false;
			if(strTempID.endsWith("T")) {
				String strHSGradID = strTempID.substring(0, strTempID.length() - 1);
				strHSGradID = dbOP.mapUIDToUIndex(strHSGradID);
				if(strHSGradID != null) {
					bolIsHSGrad = true;
					if(!SPRCIT.isMandatoryFieldFilledup(dbOP, false, strHSGradID)) 
						strLackingBasicInfo = SPRCIT.getErrMsg();
				}					
			}
			
			if(!bolIsHSGrad && !SPRCIT.isMandatoryFieldFilledup(dbOP, true, (String)vRetResult.elementAt(16))) 
				strLackingBasicInfo = SPRCIT.getErrMsg();
		  }
		  	  
  %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Untitled Document</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
    <style type="text/css">
      TABLE.thinborder {
      border-top: solid 1px #000000;
      border-right: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;	
      }

      TABLE.thinborderall {
      border: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;	
      }

      TD.thinborder {
      border-left: solid 1px #000000;
      border-bottom: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;
      }

      TD.thinborderBottom {
      border-bottom: solid 1px #000000;
      font-size: 12px;
      }
    .style1 {
	font-size: 11px;
	font-weight: bold;
}
    </style>
  </head>
  <script language="javascript" src="../../jscript/common.js"></script>
  <script language="javascript">
    function ReloadPage(){
    document.form_.print_page.value="";
    document.form_.print_pg.value="";
    this.SubmitOnce('form_');
    }
    function OpenSearch(){
    document.form_.print_page.value="";
    document.form_.print_pg.value="";
    var pgLoc = "../../search/srch_stud_temp.jsp?opner_info=form_.temp_id";
    var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
    win.focus();
    }
    function UpdateReqDocs(){
    document.form_.print_page.value="";
    document.form_.print_pg.value="";
    var pgLoc = "../registrar/admission_requirements/stud_admission_req.jsp?parent_wnd=form_&stud_id="+document.form_.temp_id.value;
    var win=window.open(pgLoc,"ReqWindow",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
    win.focus();
    }
    function EditCourse(){
    document.form_.print_page.value="";
    document.form_.print_pg.value="";
    var pgLoc = "./admission_registration_edit.jsp?parent_wnd=form_&stud_id="+document.form_.temp_id.value+
	"&proceed_clicked=1&opner_form_name=form_";
    var win=window.open(pgLoc,"ReqWindow",'dependent=yes,width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
    win.focus();
    }

	
	
    function PrintPage(){
		<%if(vRetResult != null && !WI.getStrValue((String)vRetResult.elementAt(2)).equals("Transferee") && !WI.getStrValue((String)vRetResult.elementAt(2)).startsWith("Cross") ){%>
    	if(document.form_.adm_stat.selectedIndex == 0) {
			alert("Please select application status.");
			return;
		}
		<%}%>
		document.form_.print_page.value="1";
    	document.form_.print_pg.value="";
    	this.SubmitOnce('form_');	
    }
    function PrintPg(strTempID){
    document.form_.print_pg.value="1";
    document.form_.print_page.value="";
    document.form_.temp_id.value = strTempID;
    this.SubmitOnce('form_');
    }
    function PrintALL() {
    document.form_.print_all.value = "1";
    document.form_.print_pg.value = "1";
    this.SubmitOnce('form_');
    }
  </script> 

  <body bgcolor="#D2AE72" onLoad="document.form_.temp_id.focus()">
    <form name="form_" method="post" action="./entrance_admission_slip_cit_final.jsp">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr bgcolor="#B5AB73"> 
          <td width="91%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          ENTRANCE ADMISSION SLIP::::</font></strong></div></td>
        </tr>
      </table>
      
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="5"><font size="3"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <%if(!strPrintBy.equals("1")){%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="10%">Temp ID</td>
      <td width="19%"> <input name="temp_id" type="text" class="textbox" value="<%=WI.fillTextValue("temp_id")%>" size="16" maxlength="16"
          onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"' >      </td>
      <td width="4%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="63%"><a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
      <%  if (vRetResult != null && !strPrintBy.equals("1")){
              String[] astrSemester = {"Summer", " First Semester ", "Second Semester", "Third Semester "};
      %>
      <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td height="2" colspan="4"><hr size="1" noshade></td>
        </tr>        
        <tr> 
          <td width="0%" height="25">&nbsp;</td>
          <td width="50%" height="25"> Name : <strong><%=WI.getStrValue((String)vRetResult.elementAt(7))%></strong></td>
          <td width="17%" height="25">School Year/ Term:</td>
          <td width="33%">
          <% strTemp = WI.fillTextValue("sy_from");
            if(strTemp.length() ==0)
              strTemp = strSYFrom;
          %>
          <input name="sy_from" type="text" class="textbox" size="4" maxlength="4"  value="<%=strTemp%>" 
          onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
          onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
          onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
          to 
          <%  strTemp = WI.fillTextValue("sy_to");
            if(strTemp.length() ==0)
              strTemp = strSYTo; %>
          <input name="sy_to" type="text" class="textbox" size="4" maxlength="4"
          value="<%=strTemp%>" 
          onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
          / 
          <select name="semester">
            <% strTemp = strSemester;
              if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
                strTemp = (String)request.getSession(false).getAttribute("cur_sem");
              if(strTemp.compareTo("0") ==0){%>
            <option value="0" selected>Summer</option>
            <%}else{%>
            <option value="0">Summer</option>
            <%}if(strTemp.compareTo("1") ==0){%>
            <option value="1" selected>1st Sem</option>
            <%}else{%>
            <option value="1">1st Sem</option>
            <%}if(strTemp.compareTo("2") == 0){%>
            <option value="2" selected=>2nd Sem</option>
            <%}else{%>
            <option value="2">2nd Sem</option>
            <%}
			
			if (!strSchCode.startsWith("CPU") && 
				!strSchCode.startsWith("UI")) {
			
			if(strTemp.compareTo("3") == 0){%>
            <option value="3" selected>3rd Sem</option>
            <%}else{%>
            <option value="3">3rd Sem</option>
            <%}
			} // do not show 3rd sem for CPU and UI
			%>
          </select></td>
        </tr>
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25">Temporary ID : <strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%></strong></td>
          <td height="25" colspan="2">Classification : <strong><%=WI.getStrValue((String)vRetResult.elementAt(2))%></strong></td>
        </tr>
        <tr> 
          <td height="26">&nbsp;</td>
          <td height="26">College : <strong><%=WI.getStrValue((String)vRetResult.elementAt(8))%></strong></td>
          <td height="26" colspan="2">Course/Major Applied : <strong><%=WI.getStrValue((String)vRetResult.elementAt(9))%><%=WI.getStrValue((String)vRetResult.elementAt(10),"(",")","")%></strong></td>
        </tr>
<%if(strLackingBasicInfo != null) {%>
        <tr>
          <td height="25">&nbsp;</td>
          <td colspan="3" style="font-size:14px; font-weight:bold; color:#FF0000"><%=strLackingBasicInfo%></td>
        </tr>
<%}%>
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25" colspan="3" style="font-weight:bold; font-size:14px;"><u><%if(bolIsWNU){%>Total Score<%}else{%>Placement Exams<%}%> :</u> 
          <% 
            strTemp =""; 
            if (vExamsPassed.size() > 0){
              for (int i = 0; i < vExamsPassed.size() ; i+=4){
                if (i == 0)
                  strTemp  += (String)vExamsPassed.elementAt(i) +  " ("+WI.getStrValue(applMgmt.convertTestScore(dbOP,(String)vExamsPassed.elementAt(i+2), (String)vExamsPassed.elementAt(i+1)),"xxxxx")+")" ;
                else
                  strTemp  += "," +  (String)vExamsPassed.elementAt(i) +  " ("+WI.getStrValue(applMgmt.convertTestScore(dbOP,(String)vExamsPassed.elementAt(i+2), (String)vExamsPassed.elementAt(i+1)),"xxxxx")+")" ;
              }
            }
          %> 
		  <%=strTemp%>
          <input type="checkbox" name="hide_exam" value="checked" <%=WI.fillTextValue("hide_exam")%>> <font size="1" color="#0000FF">Hide Exam Result in printing.</font>		  </td>
        </tr>
<%if(bolIsWNU){%>
        
<%}%>
        
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25" colspan="3"><br>
          Credentials Presented : <a href="javascript:UpdateReqDocs();"><img src="../../images/update.gif" width="60" height="26" border="0"></a><br> 
          <% if(vCompliedRequirement != null && vCompliedRequirement.size() > 0){%> <table width="50%" border="0" align="left" cellpadding="0" cellspacing="0" class="thinborder">
            <tr bgcolor="#F4F7FF"> 
              <td width="64%" class="thinborder">&nbsp;&nbsp;<strong>CREDENTIAL</strong></td>
              <td width="36%" class="thinborderBottom"><strong>&nbsp;&nbsp;DATE 
              PASSED</strong></td>
            </tr>
            <% for(int i = 0 ; i< vCompliedRequirement.size(); i +=3){%>
            <tr> 
              <td class="thinborder">&nbsp;<%=(String)vCompliedRequirement.elementAt(i+1)%></td>
              <td class="thinborderBottom">&nbsp;&nbsp;<%=(String)vCompliedRequirement.elementAt(i+2)%></td>
            </tr>
            <%} //end for loop%>
          </table>
          <%} // if pass or uncomplied requirementes exist %> </td>
        </tr>
        <tr> 
          <td height="15" colspan="4">&nbsp;</td>
        </tr>
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25" colspan="3">Date Admitted : <strong><%=WI.getTodaysDate()%></strong></td>
        </tr>
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25" colspan="2" style="font-weight:bold; font-size:14px;" align="right">
		  	Student Admission Status :
			<select name="adm_stat">
			<option value=""></option>
	          <%=dbOP.loadCombo("STAT_INDEX","STATUS"," from NA_ADMISSION_APPL_STAT_PRELOAD order by STAT_INDEX", request.getParameter("adm_stat"), false)%>
        	</select>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;			</td>
          <td height="25">
<%if(strLackingBasicInfo == null) {%>
		  <a href="javascript:PrintPage()"><img src="../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print admission slip</font>
<%}else{%>
			<font style="font-size:11px; font-weight:bold; color:#FF0000">Printing is BLOCKED</font>
<%}%>		  
		  </td>
        </tr>
        <tr> 
          <td height="25" colspan="4"><hr size="1"></td>
        </tr>       
      </table>
      <%}else if(false){%>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr> 
          <td width="4%" height="25">&nbsp;</td>
          <td colspan="4" height="25">School Year : 
<% strSYFrom = WI.fillTextValue("sy_from");
	if(strSYFrom.length() ==0)
	  strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
  <input name="sy_from" type="text" class="textbox" 
   onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
   onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
   onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'  value="<%=strSYFrom%>" size="4" maxlength="4">
to
<%  
	strSYTo = WI.fillTextValue("sy_to");
    if(strSYTo.length() ==0)
       strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 
%>
<input name="sy_to" type="text" class="textbox" id="sy_to" 
          onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
          value="<%=strSYTo%>" size="4" maxlength="4" readonly="yes">
&nbsp;&nbsp;

<select name="semester">
            <% strSemester = WI.fillTextValue("semester");
              if(strSemester.length() ==0 && WI.fillTextValue("page_value").length() ==0)
                strSemester = (String)request.getSession(false).getAttribute("cur_sem");
				
              if(strSemester.equals("0")){%>
            <option value="0" selected>Summer</option>
            <%}else{%>
            <option value="0">Summer</option>
            <%}if(strSemester.equals("1")){%>
            <option value="1" selected>1st Sem</option>
            <%}else{%>
            <option value="1">1st Sem</option>
            <%}if(strSemester.equals("2")){%>
            <option value="2" selected=>2nd Sem</option>
            <%}else{%>
            <option value="2">2nd Sem</option>
            <%}
			
			if (!strSchCode.startsWith("CPU") && 
				!strSchCode.startsWith("UI")) {
			
			if(strTemp.equals("3")){%>
            <option value="3" selected>3rd Sem</option>
            <%}else{%>
            <option value="3">3rd Sem</option>
            <%}
			} // do not show 3rd sem for CPU and UI
			%>
          </select>	  
		  </td>
        </tr>

        <tr>
          <td height="25">&nbsp;</td>
          <td colspan="4" height="25">Batch Code : &nbsp;&nbsp;
		<select name="exam_code">
			<option value=""> ALL</option>
			<%=dbOP.loadCombo("distinct schedule_code","schedule_code,exam_name",
			" from na_exam_sched join na_exam_name " +  
			" on (na_exam_sched.exam_name_index = na_exam_name.exam_name_index)" +
			" where na_exam_sched.is_del = 0 and na_exam_sched.is_valid = 1 " + 
			" and sy_from =" + strSYFrom +
			" and sy_to = " + strSYTo + " and semester ="  + strSemester + 
			" order by exam_name,na_exam_sched.schedule_code",WI.fillTextValue("exam_code"),false)%>
		</select>
		  
		  
		  </td>
        </tr>
        <tr>
          <td height="25">&nbsp;</td>
          <td colspan="4" height="25">&nbsp;</td>
        </tr>
        <tr> 
          <td width="4%" height="25">&nbsp;</td>
          <td colspan="4" height="25">Print students whose lastname starts with 
          <select name="lname_from" onChange="ReloadPage()">
            <%strTemp = WI.fillTextValue("lname_from");
              int j = 0; //displays from and to to avoid conflict -- check the page ;-)
              for(int i=0; i<26; ++i){
                if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
                  j = i;%>
            <option selected><%=strConvertAlphabet[i]%></option>
            <%}else{%>
            <option><%=strConvertAlphabet[i]%></option>
            <%}
                }%>
            </select>
          to 
          <select name="lname_to" onChange="ReloadPage()">
            <option value=""></option>
            <%
              strTemp = WI.fillTextValue("lname_to");

              for(int i=++j; i<26; ++i){
                if(strTemp.compareTo(strConvertAlphabet[i]) == 0){%>
            <option selected><%=strConvertAlphabet[i]%></option>
            <%}else{%>
            <option><%=strConvertAlphabet[i]%></option>
            <%}
              }%>
            </select></td>
        </tr>
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25" colspan="4">&nbsp;</td>
        </tr>
        <%if(vRetResult != null && vRetResult.size() > 0){%>
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25" colspan="4"><font size="3">TOTAL STUDENTS TO BE PRINTED
          : <strong><%=vRetResult.size()/2%></strong></font></td>
        </tr>
        <tr> 
          <td height="25">&nbsp;</td>
          <td width="16%" height="25">PRINT OPTION 1</td>
          <td width="80%" height="25" colspan="3">
          <select name="print_page_range">
            <option value="">ALL</option>
            <%
              strTemp = WI.fillTextValue("print_page_range");
              int iTemp = vRetResult.size()/2;
              int iLastCount = 0;
              for(int i = 1; i <= iTemp;){
                i += 25; //in batch of 25
                if(i > iTemp)
                  iLastCount = iTemp;
                else
                  iLastCount += 25;
                if(strTemp.compareTo(Integer.toString(iLastCount)) == 0){%>
            <option value="<%=iLastCount%>" selected><%=i - 25%> to <%=iLastCount%></option>
            <%}else{%>
            <option value="<%=iLastCount%>"><%=i - 25%> to <%=iLastCount%></option>
            <%}
                }%>
            </select></td>
        </tr>
        <tr>
          <td height="25">&nbsp;</td>
          <td>PRINT OPTION 2</td>
          <td height="25" colspan="3" valign="top">
          <input name="print_option2" type="text" size="16" maxlength="32" value="<%=WI.fillTextValue("print_option2")%>" 
          class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        </tr>
        <tr> 
          <td height="25">&nbsp;</td>
          <td height="25">&nbsp;</td>
          <td height="25" colspan="3" valign="top"><span class="style1"><font color="#0099FF">(Enter page numbers and/or page ranges 
          separated by comma. For ex: 1,3,5-12)</font></span></td>
        </tr>
      </table>      
      <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
        <tr bgcolor="#FFFFFF"> 
          <td height="25" colspan="4" align="right"><a href="javascript:PrintALL();"> 
          <img src="../../images/print.gif" border="0"></a> <font size="1">Click 
          to print</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="hidden" name="temp_id"></td>
        </tr>
        <tr bgcolor="#999999"> 
          <td height="25" colspan="4" align="center"><B>LIST OF STUDENT FOR PRINTING.</B></td>
        </tr>
        <tr bgcolor="#ffff99"> 
          <td height="19" colspan="2" align="center"><strong>STUDENT ID</strong></td>
          <td width="41%" align="center"><strong>STUDENT NAME</strong></td>
          <td width="18%" align="center"><strong>PRINT</strong></td>
        </tr>
        <%
          for(int i = 0,iCount=1; i < vRetResult.size(); i += 2,++iCount){%>
        <tr bgcolor="#FFFFFF"> 
          <td width="6%"><%=iCount%></td>
          <td width="35%" height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
          <td>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
          <td align="center"><a href='javascript:PrintPg("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/print.gif" border="0"></a></td>
        </tr>		
        <%}%>
      </table>
      <%}%>
      <%}%>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr> 
          <td>&nbsp;</td>
        </tr>
      </table>
      <table width="100%" border="0" bgcolor="#B5AB73">
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table>
      <input type="hidden" name="print_page">
      <input type="hidden" name="print_pg">
	  <input type="hidden" name="print_all">
	  
	  <input type="hidden" name="get_exam_name_index" value="1">
	  
      <% if(vRetResult != null && vRetResult.size() > 0 && !strPrintBy.equals("1")){%>
      <input  type="hidden" name="course_index" value="<%=(String)vRetResult.elementAt(14)%>">
      <input  type="hidden" name="major_index" value="<%=WI.getStrValue((String)vRetResult.elementAt(15),"0")%>">
      <input  type="hidden" name="year_level" value="<%=(String)vRetResult.elementAt(17)%>">
      <input  type="hidden" name="prep_prop_stat" value="<%=(String)vRetResult.elementAt(18)%>">
	  <input  type="hidden" name="first_entry" value="1"> 
      <%}%>
    </form>
</body>
</html>
<%
  dbOP.cleanUP();
%>