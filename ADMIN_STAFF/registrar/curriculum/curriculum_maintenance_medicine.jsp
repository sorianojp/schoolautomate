<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//call this to view course curriculum in detail.
function copyCurYr(strCYFrom, strCYTo) {
	document.cmaintenance.cy_from.value = strCYFrom;
	document.cmaintenance.cy_to.value   = strCYTo;
	this.ReloadPage();	
}
function ViewAll()
{
	var strCName = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].text;
	var strCIndex = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].value;

	//var strMName = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].text;
	//var strMIndex = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].value;

	var strSYFrom = document.cmaintenance.cy_from.value;
	var strSYTo = document.cmaintenance.cy_to.value;

	if(document.cmaintenance.course_index.selectedIndex < 0)
	{
		alert("Please select a course.");
		return;
	}
	if(strSYFrom.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}
	if(strSYTo.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}

	//if(document.cmaintenance.major_index.selectedIndex == 0) //major index is null
	{
		location = "./curriculum_maintenance_medicine_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo;
	}
	/*else
	{
		location = "./curriculum_maintenance_medicine_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo+"&mi="+strMIndex+"&mname="+escape(strMName);
	}*/
}
function AddRecord()
{
	document.cmaintenance.addRecord.value = 1;
	document.cmaintenance.editRecord.value = 0;
	document.cmaintenance.deleteRecord.value = 0;
	document.cmaintenance.reloadPage.value = 0;
	//document.cmaintenance.changeSubject.value = 0;
}
function DeleteRecord()
{
	document.cmaintenance.addRecord.value = 0;
	document.cmaintenance.editRecord.value = 0;
	document.cmaintenance.deleteRecord.value = 1;
	document.cmaintenance.reloadPage.value = 0;
	//document.cmaintenance.changeSubject.value = 0;
}
function EditRecord()
{
	document.cmaintenance.addRecord.value = 0;
	document.cmaintenance.editRecord.value = 1;
	document.cmaintenance.deleteRecord.value = 0;
	document.cmaintenance.reloadPage.value = 0;
	//document.cmaintenance.changeSubject.value = 0;
}
function ReloadPage()
{
	document.cmaintenance.addRecord.value = 0;
	document.cmaintenance.editRecord.value = 0;
	document.cmaintenance.deleteRecord.value = 0;
	document.cmaintenance.reloadPage.value = 1;

	document.cmaintenance.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = new Vector();//this is added to store the subject descirption, category name and category index for Pre-requisite

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - medicine","curriculum_maintenance_medicine.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance_medicine.jsp");
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

boolean bolProceed = true;
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumMaintenance CM = new CurriculumMaintenance();
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(CM.createCOMCur(dbOP,request))
		strErrMsg = "Curriculum added successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = CM.getErrMsg();
	}
}
else //for edit or delete
{
	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		//add it here and give a message.
		if(CM.editCOMCur(dbOP,request))
			strErrMsg = "Curriculum edited successfully.";
		else
		{
			bolProceed = false;
			strErrMsg = CM.getErrMsg();
		}
	}
	else //for delete
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			//add it here and give a message.
			if(CM.deleteCOMCur(dbOP,request))
				strErrMsg = "Information removed from curriculum successfully.";
			else
			{
				bolProceed = false;
				strErrMsg = CM.getErrMsg();
			}
		}
	}
}

if(!bolProceed)
{
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	return;
}
%>

<form name="cmaintenance" method="post" action="./curriculum_maintenance_medicine.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="3"> <%
if(strErrMsg == null) strErrMsg = "";
%> <font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="37%">Course </td>
      <td width="25%">&nbsp;</td>
      <td width="36%">Curriculum year </td>
    </tr></tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><select name="course_index">
          <%//get course offerd for doctoral/masters.
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and degree_type=2 and course_index="+
			request.getParameter("course_index")+" order by course_name asc";
//System.out.println(strTemp);
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
        </select></td>
      <td><input name="cy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','cy_from');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('cmaintenance','cy_from')">
        to 
        <input name="cy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','cy_to');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('cmaintenance','cy_to')"> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>
        <%
Vector vCurYearInfo = null;
strTemp = null;
if(WI.fillTextValue("course_index").length() == 0 || WI.fillTextValue("course_index").compareTo("selany") == 0) 
	strTemp = null;
else	
	strTemp = WI.fillTextValue("major_index");

vCurYearInfo = new enrollment.SubjectSection().getSchYear(dbOP, request.getParameter("course_index"),strTemp);
if(vCurYearInfo != null) {
%>
        <strong><font color="#0000FF" size="1">Existing Cur Year:</font> </strong><br> 
        <%
		for(int i = 0; i < vCurYearInfo.size(); i += 2) {%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%i = i + 2;
		if(i < vCurYearInfo.size()){%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%}//show two in one line.%>
        <br> 
        <%}%>
        <%}//only if cur info is not null;
%>
      </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong>To filter SUBJECT display enter subject code starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:15px">
        and click REFRESH</strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="6%"><a href="javascript:ViewAll();" target="_self">
	  <img src="../../../images/view.gif" border="0"></a></td>
      <td width="68%" valign="bottom"><font size="1">click to view complete curriculum 
        OR click to reload page. <a href="javascript:ReloadPage();" target="_self"><img src="../../../images/refresh.gif" border="0"></a></font></td>
    </tr>
    <tr valign="middle">
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="16%" height="25">Year
        <select name="year">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("year");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}%>
        </select> </td>
      <td width="23%" height="25">Term
        <select name="semester">
 <!--         <option value="">No Sem</option>-->
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select> </td>
      <td height="25">
<%
strTemp = WI.fillTextValue("is_internship");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else strTemp = "";
%><!--	  <input type="checkbox" name="is_internship" value="1" <%=strTemp%> onClick="ReloadPage();">
        Check if Internship Subject--></td>
      <td width="8%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td  height="25" valign="bottom"><font size="1"><strong>MAIN SUBJECT CODE</strong></font></td>
      <td valign="bottom"><font size="1"><strong>DESCRIPTION </strong></font></td>
      <td valign="bottom"><font size="1"><strong>TOTAL LOAD</strong></font></td>
      <td width="15%" valign="bottom"><div align="left"><font size="1"><strong>GRADING</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="main_subject" onChange="ReloadPage();" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 12px;width: 600px;">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", request.getParameter("main_subject"), false)%> 
        </select></td>
      <td>
<%
strTemp = WI.fillTextValue("main_unit");
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(3)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(3);//get if already created
%>
	  <input name="main_unit" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="load">
          <option >Unit</option>
          <%
strTemp = WI.fillTextValue("load");
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(4)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(4);//get if already created


if(strTemp.compareTo("Hour") ==0){%>
          <option selected>Hour</option>
          <%}else{%>
          <option>Hour</option>
          <%}if(strTemp.compareTo("Month") ==0){%>
          <option selected>Month</option>
          <%}else{%>
          <option>Month</option>
          <%}if(strTemp.compareTo("Weeks") ==0){%>
          <option selected>Weeks</option> 
          <%}else{%>
          <option>Weeks</option>
          <%}%>
        </select></td>
      <td ><select name="grading">
          <option value="1">Yearly</option>
          <%
strTemp = WI.fillTextValue("grading");
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(5)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(5);//get if already created
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Semestral</option>
          <%}else{%>
          <option value="0">Semestral</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td  height="25" colspan="3" valign="bottom"><strong><font size="1">SUBJECT 
        GROUP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong> <select name="group_name">
          <%
strTemp = WI.fillTextValue("main_subject");
if(strTemp.length() > 0 && strTemp.compareTo("0") != 0 && strTemp.compareTo("selany") != 0)
	strTemp = dbOP.mapOneToOther("SUBJECT","sub_index",strTemp,"GROUP_INDEX",null);
else	
	strTemp = "";
%>
          <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", strTemp, false)%> </select></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <%
//if it is internship -- there is no sub subject.
if(WI.fillTextValue("is_internship").compareTo("1") != 0 && false){//do not show sub subject anymore.. only used in vmuf. %>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td  height="25" colspan="3" valign="bottom">Check if main subject is having 
        sub subject 
        <%
strTemp = WI.fillTextValue("is_sub");
if(strTemp.compareTo("1") ==0){%> <input type="checkbox" name="is_sub" value="1" onClick="ReloadPage();" checked> 
        <%}else{%> <input type="checkbox" name="is_sub" value="1" onClick="ReloadPage();"> 
        <%}%> </td>
      <td width="15%" valign="bottom"><div align="left"></div></td>
    </tr>
    <%
if(strTemp.compareTo("1") ==0){%>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="22%"  height="25" valign="bottom"><div align="left"><font size="1"><strong>SUBJECT 
          CODE</strong></font></div></td>
      <td width="38%" valign="bottom"><div align="left"><font size="1"><strong>DESCRIPTION 
          </strong></font></div></td>
      <td width="24%" valign="bottom"><font size="1"><strong>LOAD</strong></font></td>
      <td width="15%" valign="bottom"><div align="left"></div></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="sub_subject" onChange="ReloadPage();">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", request.getParameter("sub_subject"), false)%> 
        </select></td>
      <td > <%
strTemp = dbOP.mapOneToOther("SUBJECT", "SUB_INDEX", request.getParameter("sub_subject"), "SUB_NAME"," and is_del=0");
if(strTemp == null) strTemp = "";
%> <%=strTemp%></td>
      <td ><input name="sub_unit" type="text" size="5" value="<%=WI.fillTextValue("sub_unit")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
      </td>
      <td >&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <%}//if it is internship -- there is no sub subject.
%>
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  colspan="4" height="25" > <div align="center"> 
          <%if(iAccessLevel > 1){%>
          <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif">
          <font size="1">click to save subject 
          <input name="image" type="image" onClick="EditRecord();" src="../../../images/edit.gif" border="0">
          click to edit subject 
          <%if(iAccessLevel ==2){%>
          <input name="image" type="image" onClick="DeleteRecord();" src="../../../images/delete.gif">
          click to delete subject 
          <%}else{%>
          Not authorized to delete 
          <%}%>
          </font> 
          <%}else{%>
          Not authorized to add/edit/delete 
          <%}%>
        </div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25"  colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="change_course_index"><!-- only when course index is changed. -->

</form>
</body>
</html>
<%dbOP.cleanUP();%>
