<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CURRICULUM-nosem</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	location = "./curriculum_maintenance_nosem_viewall.jsp?course_index="+strCIndex+"&cname="+escape(strCName)+
		"&cy_from="+strSYFrom+"&cy_to="+strSYTo;
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
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = new Vector();//this is added to store the subject descirption, category name and category index for Pre-requisite

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - nosem","curriculum_maintenance_nosem.jsp");
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
														"curriculum_maintenance_nosem.jsp");
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
	if(CM.operateOnCurWithNoSem(dbOP,request,1) != null)
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
		if(CM.operateOnCurWithNoSem(dbOP,request,2) != null)
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
			if(CM.operateOnCurWithNoSem(dbOP,request,0) != null)
				strErrMsg = "Subject removed from curriculum.";
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

<form name="cmaintenance" method="post" action="./curriculum_maintenance_nosem.jsp">
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
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and DEGREE_TYPE=4 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
        </select></td>
      <td><input name="cy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('cmaintenance','cy_from');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('cmaintenance','cy_from')">
        to 
        <input name="cy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('cmaintenance','cy_to');style.backgroundColor='white'"
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
      <td colspan="3"><strong>To filter SUBJECT display enter subject code starts 
        with 
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

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" rowspan="2">&nbsp;</td>
      <td  height="25" rowspan="2" valign="bottom"><font size="1"><strong>MAIN 
        SUBJECT CODE</strong>
        <input type="text" name="scroll_sub" size="8" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','main_subject',true,'cmaintenance');">
        (scroll)</font></td>
      <td rowspan="2" valign="bottom"><font size="1"><strong>DESCRIPTION </strong></font></td>
      <td colspan="2" valign="bottom"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
      <td width="16%" rowspan="2" valign="bottom"><div align="left"><font size="1"></font></div></td>
    </tr>
    <tr> 
      <td width="5%" valign="bottom"><div align="center"><strong><font size="1">LEC.</font></strong></div></td>
      <td width="5%" valign="bottom"><div align="center"><strong><font size="1">LAB</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td  height="25"><font size="1"> 
        <select name="main_subject" onChange="ReloadPage();"style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", request.getParameter("main_subject"), false)%> 
        </select>
        </font></td>
      <td> <font size="1"> 
        <%
strTemp = dbOP.mapOneToOther("SUBJECT", "SUB_INDEX", request.getParameter("main_subject"), "SUB_NAME"," and is_del=0");
if(strTemp == null) strTemp = "";
%>
        <%=strTemp%></font></td>
      <td><div align="center"><font size="1"> 
          <input name="main_lec" type="text" size="3" value="<%=WI.fillTextValue("main_lec")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
          </font></div></td>
      <td><div align="center"><font size="1"> 
          <input name="main_lab" type="text" size="3" value="<%=WI.fillTextValue("main_lab")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
          </font></div></td>
      <td ><font size="1"> 
        <%
strTemp = WI.fillTextValue("is_optional");
if(strTemp.compareTo("1") ==0){%>
        <input type="checkbox" name="is_optional" value="1" checked>
        <%}else{%>
        <input type="checkbox" name="is_optional" value="1">
        <%}%>
        OPTIONAL </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td  height="25" colspan="4" valign="bottom"><strong><font size="1">SUBJECT 
        GROUP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong> <select name="group_name">
          <%
strTemp = WI.fillTextValue("main_subject");
if(strTemp.length() > 0 && strTemp.compareTo("0") != 0 && strTemp.compareTo("selany") != 0)
	strTemp = dbOP.mapOneToOther("SUBJECT","sub_index",strTemp,"GROUP_INDEX",null);
else	
	strTemp = "";
%>
          <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", strTemp, false)%> 
        </select> </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td  height="25" colspan="4" valign="bottom"><font size="1">Check if main 
        subject is having sub subject 
        <%
strTemp = WI.fillTextValue("is_sub");
if(strTemp.compareTo("1") ==0){%>
        <input type="checkbox" name="is_sub" value="1" onClick="ReloadPage();" checked>
        <%}else{%>
        <input type="checkbox" name="is_sub" value="1" onClick="ReloadPage();">
        <%}%>
        </font></td>
      <td width="16%" valign="bottom"><div align="left"><font size="1"></font></div></td>
    </tr>
    <%
if(strTemp.compareTo("1") ==0){%>
    <tr> 
      <td width="0%" height="25" rowspan="2">&nbsp;</td>
      <td width="28%"  height="25" rowspan="2" valign="bottom"><div align="left"><font size="1"><strong>SUBJECT 
          CODE</strong>
          <input type="text" name="scroll_sub2" size="8" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub2','sub_subject',true,'cmaintenance');">
          (scroll)</font></div></td>
      <td width="46%" rowspan="2" valign="bottom"><div align="left"><font size="1"><strong>DESCRIPTION 
          </strong></font></div></td>
      <td colspan="2" valign="bottom"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
      <td width="16%" rowspan="2" valign="bottom"><div align="left"><font size="1"></font></div></td>
    </tr>
    <tr> 
      <td width="5%" valign="bottom"><div align="center"><strong><font size="1">LEC.</font></strong></div></td>
      <td width="5%" valign="bottom"><div align="center"><strong><font size="1">LAB</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="sub_subject" onChange="ReloadPage();"style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", request.getParameter("sub_subject"), false)%> 
        </select>
        <font size="1">&nbsp; </font></td>
      <td > <%
strTemp = dbOP.mapOneToOther("SUBJECT", "SUB_INDEX", request.getParameter("sub_subject"), "SUB_NAME"," and is_del=0");
if(strTemp == null) strTemp = "";
%> <%=strTemp%></td>
      <td><div align="center"><font size="1"> 
          <input name="sub_lec" type="text" size="3" value="<%=WI.fillTextValue("sub_lec")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
          </font></div></td>
      <td><div align="center"><font size="1"> 
          <input name="sub_lab" type="text" size="3" value="<%=WI.fillTextValue("sub_lab")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
          </font></div></td>
      <td ><font size="1">&nbsp; </font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  colspan="5" height="25" > <div align="center"> 
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
      <td height="25"  colspan="5">&nbsp;</td>
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

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%dbOP.cleanUP();%>
