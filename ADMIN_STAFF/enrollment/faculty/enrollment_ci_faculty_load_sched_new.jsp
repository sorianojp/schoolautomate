<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CI Faculty Loading</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function LoadHospitalLists(){
	location = "./enrollment_ci_faculty_load_sched_hosp.jsp?emp_id="+document.form_.emp_id.value+
	"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value;
}
function AddRecord(){
	document.form_.print_page.value = "0";
	document.form_.page_action.value ="1";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.print_page.value = "0";
	document.form_.page_action.value ="2";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.print_page.value = "0";
	document.form_.page_action.value ="0";
	document.form_.info_index.value= strInfoIndex;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.print_page.value = "0";
	document.form_.prepareToEdit.value="1";
	document.form_.info_index.value= strInfoIndex;
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./enrollment_ci_faculty_load_sched_new.jsp?emp_id="+escape(document.form_.emp_id.value)+
			"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value;
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
	
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//add security here.
	if (WI.fillTextValue("print_page").equals("1")){
%>
	<jsp:forward page="./enrollment_ci_faculty_load_sched_print.jsp" />
<%	return;
	}

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-LOADING(CLINICAL SCHEDULE)"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}



	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-load CI schedule","enrollment_ci_faculty_load_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"enrollment_faculty_ci_load_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/
//end of authenticaion code.

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
FacultyManagement FM = new FacultyManagement();
Vector vRetResult = null;
Vector vUserDetail = null;
Vector vRetEdit  = null;
String[] astrConverSem={" Summer"," 1st Sem"," 2nd Sem"," 3rd Sem"};
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

	strTemp = WI.fillTextValue("emp_id");
	
	if (strTemp.length() > 0)
	{
		strTemp = dbOP.mapOneToOther("USER_TABLE","ID_NUMBER","'" + strTemp+"'","user_index"," and is_del = 0");

		if ( strTemp != null) {
			vUserDetail = FM.viewFacultyDetail(dbOP,strTemp,WI.fillTextValue("sy_from"),
											WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
			if(vUserDetail == null)
				strErrMsg = FM.getErrMsg();
			else
			{				
				if (WI.fillTextValue("page_action").equals("0")){	
					if (FM.operateOnFacultyLoadCI(dbOP,request,0) != null) 
						strErrMsg = "Hospital Record removed successfully.";
					else
						strErrMsg = FM.getErrMsg();
				}else if (WI.fillTextValue("page_action").equals("1")){
					if (FM.operateOnFacultyLoadCI(dbOP,request,1) != null) 
						strErrMsg = "Hospital Record saved successfully.";
					else
						strErrMsg = FM.getErrMsg();
				
				}else if (WI.fillTextValue("page_action").equals("2")){
					if (FM.operateOnFacultyLoadCI(dbOP,request,2) != null) 
						strErrMsg = "Hospital Record edited successfully.";
					else
						strErrMsg = FM.getErrMsg();
				}
				
				if (strPrepareToEdit.compareTo("1") == 0){
					vRetEdit = FM.operateOnFacultyLoadCI(dbOP,request,3);
					if (vRetEdit == null) 
						strErrMsg = FM.getErrMsg();
				}
				
				vRetResult = FM.operateOnFacultyLoadCI(dbOP,request,4);
				
			}
		}else{ 
			strErrMsg = " Please enter a valid faculty ID.";
		}
	}else{
		strErrMsg = " Please enter faculty ID.";
	}
if(strErrMsg == null) strErrMsg = "";

//System.out.println(vRetEdit);

%>

<form action="./enrollment_ci_faculty_load_sched_new.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY PAGE - CLINICAL INSTRUCTOR LOADING/SCHEDULING ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="4"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td  width="15%" height="25">Academic Year</td>
      <td width="18%" height="25"><strong><%=WI.fillTextValue("sy_from")%>
        <input name="sy_from" type="hidden" value="<%=WI.fillTextValue("sy_from")%>">
        to <%=WI.fillTextValue("sy_to")%> 
        <input name="sy_to" type="hidden" value="<%=WI.fillTextValue("sy_to")%>">
        </strong></td>
      <td width="6%">Term</td>
      <td width="59%"><strong><input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>"><%=astrConverSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Employee ID </td>
      <td height="25"><input name="emp_id" type="hidden" value="<%=WI.fillTextValue("emp_id")%>"> 
        <strong><%=WI.fillTextValue("emp_id")%></strong></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if (vUserDetail != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td  colspan="2" height="15"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td>Employee Name : <strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> College : <strong><%=(String)vUserDetail.elementAt(4)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td > Position : <strong><%=(String)vUserDetail.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Employment Status : <strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="1%" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="16%" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="83%" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Subject </td>
      <td bgcolor="#FFFFFF"> <select name="sub_sec_index">
<%
	if (vRetEdit != null) strTemp = (String)vRetEdit.elementAt(2);
	else strTemp = 	WI.fillTextValue("sub_sec_index");
	
	if (!strSchCode.startsWith("UI")){ %>
      <%=dbOP.loadCombo("sub_sec_index","sub_code +'&nbsp;(' + section +')' ",
				" from e_sub_section join subject on (e_sub_section.sub_index = subject.sub_index) " +
				" where offering_sy_from = " +  WI.fillTextValue("sy_from")  + "and offering_sem =" +
				WI.fillTextValue("semester") + " and e_sub_section.is_del = 0" +
				" and e_sub_section.is_valid = 1 and " + 
				" (sub_code = 'PHC01a' or sub_code = 'PHC02' or " +
				" sub_code ='PHC I' or sub_code ='PHC II' or " + 
				" ((sub_code like '%rle%' or sub_name like '%rle%')" +
				" and exists ( select curriculum.cur_index  from curriculum  " + 
				" where curriculum.sub_index  = subject.sub_index" + 
				" 	and curriculum.hour_lab > 10 and course_index > 0 and curriculum.is_del = 0 " + 
 				" and curriculum.is_valid = 1))) ",strTemp,false)%>		
	
	<%}else {//for UI.%>
      <%=dbOP.loadCombo("max(sub_sec_index)","sub_code",
				" from e_sub_section join subject on (e_sub_section.sub_index = subject.sub_index) " +
				" where offering_sy_from = " +  WI.fillTextValue("sy_from")  + "and offering_sem =" +
				WI.fillTextValue("semester") + " and e_sub_section.is_del = 0" +
				" and e_sub_section.is_valid = 1 and (sub_code like 'NCM%' or sub_code like '%rle%' or sub_name like '%rle%')" +
				" and exists ( select curriculum.cur_index  from curriculum  " + 
				" where curriculum.sub_index  = subject.sub_index" + 
				" 	and curriculum.hour_lab > 10 and course_index > 0 and curriculum.is_del = 0 " + 
 				" and curriculum.is_valid = 1) group by sub_code",strTemp,false)%>		
	<%}%>
				 </select></td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Day </td>
      <td bgcolor="#FFFFFF"> <%
	  	if (vRetEdit != null) strTemp = WI.getStrValue((String)vRetEdit.elementAt(3));
		else strTemp = WI.fillTextValue("week_day");
	  %> <input name="week_day" type="text"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" maxlength="16" > 
      </td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Schedule (Time)</td>
      <td bgcolor="#FFFFFF"> <%
	  	if (vRetEdit != null) strTemp = WI.getStrValue((String)vRetEdit.elementAt(4));
		else strTemp = WI.fillTextValue("schedule");
	  %> <input name="schedule" type="text"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" maxlength="16"></td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Hospital </td>
      <td bgcolor="#FFFFFF"><select name="hospital_index">
          <%
	  	if (vRetEdit != null) strTemp = (String)vRetEdit.elementAt(1);
		else strTemp = WI.fillTextValue("hospital_index");
	  %>
          <%=dbOP.loadCombo("FAC_HOSPITAL_INDEX","HOSP_CODE +'::'+HOSP_NAME", 
	  					" from FAC_PRELOAD_HOSPITAL where is_del = 0 and is_valid = 1 order by HOSP_CODE", strTemp, false)%> </select> <a href="javascript:LoadHospitalLists()"><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF"> Area of Assignment</td>
      <td bgcolor="#FFFFFF"> <select name="aor">
          <option value=""></option>
          <%
	if (vRetEdit != null) 
		strTemp = (String)vRetEdit.elementAt(15);
	else strTemp = WI.fillTextValue("aor");
%>
          <%=dbOP.loadCombo("HOSP_AREA_INDEX","HOSP_AREA_NAME"," from fac_preload_hosp_area order by hosp_area_name",strTemp,false)%> </select> 
     <a href='javascript:viewList("fac_preload_hosp_area","HOSP_AREA_INDEX","HOSP_AREA_NAME","HOSPITAL AREA",
		"FACULTY_LOAD_CI","HOSP_AREA_INDEX", " and FACULTY_LOAD_CI.IS_VALID = 1","","aor")'>		  
		  
		  <img src="../../../images/update.gif" border="0">
		  </a>
		  </td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Duration</td>
      <td bgcolor="#FFFFFF"> <%
	if (vRetEdit != null) 
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(5));
	else strTemp = WI.fillTextValue("duration");
%> <input name="duration" type="text" size="4" maxlength="4"  class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','duration')" onKeyUp="AllowOnlyFloat('form_','duration')"> 
	  
        <select name="duration_type">
          <option value="0"> Hours</option>
<% if (false && !strSchCode.startsWith("UI")) {
	if (vRetEdit != null) strTemp = (String)vRetEdit.elementAt(6);
 		else strTemp = WI.fillTextValue("duration_type"); 

   if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected> Days</option>
          <%}else{%>
          <option value="1"> Days</option>
          <%} if (strTemp.compareTo("2") == 0) {%>
          <option value="2" selected> Weeks</option>
          <%}else{%>
          <option value="2"> Weeks</option>
          <%} if (strTemp.compareTo("3") == 0) {%>
          <option value="3" selected> Months</option>
          <%}else{%>
          <option value="3"> Months</option>
          <%}
  } // hide for everyone na :P.. 
		  %>
        </select>
		
		</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Start Date</td>
      <td bgcolor="#FFFFFF"> <%
	if (vRetEdit != null) 
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(7));
	else strTemp = WI.fillTextValue("date_from");
%> <input name="date_from" type="text"  class="textbox"
  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" size="18" maxlength="24"> 
      </td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">End Date</td>
      <td bgcolor="#FFFFFF"> <%
	if (vRetEdit != null) 
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(8));
	else strTemp = WI.fillTextValue("date_to");
%> <input name="date_to" type="text"  class="textbox"
  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="18" maxlength="24"> 
      </td>
    </tr>
    <tr> 
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="30" bgcolor="#FFFFFF"> <% if (iAccessLevel > 1){%> <font size="1"> 
        <% if (vRetEdit == null) {%>
        <a href="javascript:AddRecord()"><img src="../../../images/save.gif" border="0"></a>click 
        to save schedule 
        <%}else {%>
        <a href="javascript:EditRecord()"><img src="../../../images/edit.gif" border="0"></a>click 
        to edit schedule <a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" border="0"></a>click 
        to cancel edit 
        <%}%>
        </font> <%} // end if accesslevel > 1%> </td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>

<% if (vRetResult != null) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FAF5F9"> 
      <td height="25" colspan="7" align="center" class="thinborder"><strong><font color="#0000FF">CLINICAL 
        INSTRUCTOR LOAD SCHEDULE </font></strong></td>
    </tr>
    <tr> 
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>SUBJECT</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="21%" align="center" class="thinborder"><font size="1"><strong>HOSPITAL/CLINIC 
        NAME<br>
        ADDRESS</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong> 
        AREA OF ASSIGNMENT</strong></font></td>
<% if (strSchCode.startsWith("UI"))
		strTemp = " No. of Hours/Week";
	else
		strTemp = " Duration ";
%>

      <td width="10%" height="27" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">INCLUSIVE 
        DATES </font></strong></td>
      <td width="14%" align="center" class="thinborder"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
    <%  String[] astrConvType ={" Hour(s)"," Day(s)"," Week(s)"," Month(s)"};
		for (int i = 1; i < vRetResult.size(); i+=15) {%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%> &nbsp;
<% if (!strSchCode.startsWith("UI")) {%>
	  (<%=(String)vRetResult.elementAt(i+13)%>)
<%}%>
	  </td>
	 <%
	 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2));
		if (strTemp.length() > 0) {
			strTemp +=  WI.getStrValue((String)vRetResult.elementAt(i+3)," :: ","","");
		}else{
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
		}
	 %> 
	  
      <td class="thinborder">&nbsp; <%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+8)%><br>&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
     <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"",astrConvType[Integer.parseInt((String)vRetResult.elementAt(i+5))],"&nbsp;")%> </td>
      <td class="thinborder">&nbsp; 
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
		if (strTemp.length() > 0) {
			strTemp +=  WI.getStrValue((String)vRetResult.elementAt(i+7)," to ","","");
		}else{
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7));
		}
	%> 
	  <%=strTemp%>
	  </td>
      <td class="thinborder">
<% if (iAccessLevel > 1) {%>
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a>
<%} if(iAccessLevel == 2){%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
<%}%></td>
    </tr>
    <%} // end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td width="88%" height="25"><div align="center">
	  <a href="javascript:PrintPage()">
	  <img src="../../../images/print.gif" width="58" height="26" border="0"></a>
          <font size="1">click to print load</font></div></td>
    </tr>
  </table>
<%
  } // end vRetResult != null
} // if vUserDetails != null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" >&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit">
<input type="hidden" name="print_page" value="0">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
