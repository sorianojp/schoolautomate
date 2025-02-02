<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function ViewDetails(strInfoIndex, strStudIndex)
{
	var pgLoc = "./mental_ability_detail.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
<!--
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function EmpSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID()
{
	document.form_.stud_id.focus();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +"&opner_form_name=form_";
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	}
-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDMentalAbility, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vBasicInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Mental Ability Test Result-Encode Result","encode_mental_ability.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","Mental Ability Test Result",request.getRemoteAddr(),
														"encode_mental_ability.jsp");
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

//end of authenticaion code.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0) 
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));

if (vBasicInfo!=null && vBasicInfo.size()>0){
	GDMentalAbility GDAbility = new GDMentalAbility();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDAbility.operateOnMentalAbility(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = GDAbility.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = GDAbility.operateOnMentalAbility(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = GDAbility.getErrMsg();
	}

			
	vRetResult = GDAbility.operateOnMentalAbility(dbOP, request, 4);
	
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDAbility.getErrMsg();
}
else
	strErrMsg = OAdm.getErrMsg();
%>
<body bgcolor="#663300" onload="FocusID();">
<form action="./encode_mental_ability.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING : MENTAL ABILITY TEST RESULT ENTRY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="3" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="45%">School Year : 
        <% if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(3);
        else
       		 strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(4);
        else
			strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <%
          if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(5);
        else
			strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
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
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}%>
</select></td>
      <td width="50%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student ID &nbsp;: 
        <%strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">  </td>
      <td height="25"><a href="javascript:StudSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for student ID</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Examination: 
      <%
        if (vEditInfo != null && vEditInfo.size()>0)
      		  strTemp = (String)vEditInfo.elementAt(7);
        else
        	  strTemp = WI.fillTextValue("exam_date");%>
        <input name="exam_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <%if (vBasicInfo!= null && vBasicInfo.size()>0){
	strTemp =(String)vBasicInfo.elementAt(19);
    %>
    <tr> 
      <td height="25" colspan="3"> <div align="right"> 
          <hr size="1">
        </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Birthdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>

    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="top"><strong>RESULT :</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="top">Raw Score : 
        <%
        if (vEditInfo != null && vEditInfo.size()>0)
        strTemp = (String)vEditInfo.elementAt(8);
        else
        strTemp = WI.fillTextValue("raw_score");%>
    <input name="raw_score" type="text" id="raw_score" size="12" maxlength="12" class="textbox"
        onKeyUp= 'AllowOnlyInteger("form_","raw_score")' onfocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","raw_score");style.backgroundColor="white"' value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Classification of IQ : 
         <%
        if (vEditInfo != null && vEditInfo.size()>0)
    	    strTemp = (String)vEditInfo.elementAt(1);
        else
	         strTemp = WI.fillTextValue("iq_class");%>
         <select name="iq_class">
          <option value="">Select Classification</option>
			<%=dbOP.loadCombo("IQ_CLASS_INDEX","CLASSIFICATION"," FROM GD_IQ_CLASSIFICATION ORDER BY CLASSIFICATION", strTemp, false)%>
        </select> <font size="1">
          <a href='javascript:viewList("GD_IQ_CLASSIFICATION","IQ_CLASS_INDEX","CLASSIFICATION","IQ CLASSIFICATION",
	"GD_MENTAL_ABILITY","IQ_CLASS_INDEX", " and GD_MENTAL_ABILITY.IS_DEL = 0 AND GD_MENTAL_ABILITY.IS_VALID = 1","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click 
        to update list of medication names</font></td>
    </tr>
    <tr> 
      <td height="90">&nbsp;</td>
      <%
        if (vEditInfo != null && vEditInfo.size()>0)
    	    strTemp = (String)vEditInfo.elementAt(13);
        else
	    	strTemp = WI.fillTextValue("remarks");%>
      <td colspan="2">Remarks :<br> <textarea name="remarks" cols="50" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="34">&nbsp;</td>
      <td height="34" colspan="2" valign="bottom">Psychometrician (Employee ID) 
        : 
        <%
        if (vEditInfo != null && vEditInfo.size()>0)
    	    strTemp = (String)vEditInfo.elementAt(9);
        else
	        strTemp = WI.fillTextValue("emp_id");%>
     <input name="emp_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
	  <a href="javascript:EmpSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for employee ID</font>
      </td>
    </tr>
    <tr> 
      <td height="60">&nbsp;</td>
      <td height="60" colspan="2" valign="bottom"><div align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
        <%}//if info exists%>
  </table>
<%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr > 
      <td height="25" colspan="10" bgcolor="#FFFF9F" class="thinborder"><div align="center"><strong>MENTAL ABILITY TEST RESULTS</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF" > 
      <td width="25%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SCHOOL
      YEAR/SEMESTER
      </strong></font></div></td>
      <td width="8%" class="thinborder"> <div align="center"><font size="1"><strong>EXAM
      DATE
      </strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>RAW
      SCORE
      </strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>IQ
      CLASS
      </strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong><font size="1">REMARKS</font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>PSYCHOMETRICIAN</strong></font></div></td>
      <td width="14%" class="thinborder" colspan="2">&nbsp;</td>
    </tr>
<%for (int i = 0; i< vRetResult.size(); i+=14){%>
    <tr bgcolor="#FFFFFF" > 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(i+4)%>&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1">
      <%strTemp = (String)vRetResult.elementAt(i+13);
      if (strTemp.length()>20){%>
      <%=strTemp.substring(0,20)%><a href='javascript:ViewDetails("<%=((String)vRetResult.elementAt(i))%>","<%=((String)vRetResult.elementAt(i+6))%>")'>...more</a><%}else{%><%=strTemp%><%}%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12),7)%></font></div></td>
      <td width="7%" class="thinborder"><font size="1"> 
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></td>
      <td width="7%" class="thinborder"><font size="1"> <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%></font></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
