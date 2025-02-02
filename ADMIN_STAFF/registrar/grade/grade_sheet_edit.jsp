<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function EditRecord(strInfo,strEditCount)
{
	document.gsheet.info_index.value=strInfo;
	document.gsheet.edit_ref.value=strEditCount;
	document.gsheet.page_action.value="1";//for edit
	this.SubmitOnce('gsheet');
}
function PageAction(strAction)
{
	document.gsheet.page_action.value=strAction;
	this.SubmitOnce('gsheet');
}
function ReloadPage()
{
	this.SubmitOnce('gsheet');
}

</script>


<body bgcolor="#D2AE72">
<form name="gsheet" action="./grade_sheet.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector " %>
<%

	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheet EDIT","grade_sheet_edit.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),
									null);

}
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

Vector vSectionDetail = null;//schedule and instructor name,
GradeSystem GS = new GradeSystem();
vSectionDetail = GS.getSectionDetail(dbOP, request.getParameter("sub_section"));
if(vSectionDetail == null && WI.fillTextValue("sub_section") != null && WI.fillTextValue("sub_section").compareTo("0") != 0)
	strErrMsg = GS.getErrMsg();

if(strErrMsg == null)
{
	if(WI.fillTextValue("page_action").compareTo("1") ==0) //save grade sheet.
	{
		if(GS.editGradeSheetOfAStud(dbOP, request))
			strErrMsg = "Grade edited successfully.";
		else
			strErrMsg = GS.getErrMsg();
	}
}

if(strErrMsg == null) strErrMsg = "";
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="25%" height="25" valign="bottom" >Grades for </td>
      <td width="22%" valign="bottom" >Term </td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="8%" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom" ><strong>
        <select name="grade_for">
          <%=dbOP.loadCombo("EXAM_NAME","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%>
        </select>
        </strong> </td>
      <td valign="bottom" ><select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td valign="bottom" ><input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td colspan="2" ><input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage();">
      </td>
      <td width="8%" >&nbsp;</td>
    </tr>
</table>
<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

    <tr>
      <td width="1%"></td>
	  <td width="39%" height="25" valign="bottom" >College </td>
      <td colspan="2" valign="bottom" >Department </td>
    </tr>
    <tr><td></td>
      <td height="25" > <select name="c_index" onChange="ReloadPage();">
          <option value="0">Select a college</option>
<%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", request.getParameter("c_index"), false)%>
        </select> </td>
      <td colspan="2" > <select name="d_index">
<%
//only if there is a college selected.
if(WI.fillTextValue("c_index").length() > 0){%>
<%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+request.getParameter("c_index")+" order by d_name asc",
		  	request.getParameter("d_index"), false)%>
          <%}%>
</select> </td>
    </tr>
    <tr>
      <td width="1%"></td>
	  <td height="25">Subject Code </td>
      <td width="30%">Subject Section</td>
      <td width="30%">Subject Name</td>
    </tr>
    <tr> <td width="1%"></td>
      <td height="25" > <select name="sub_code" onChange="ReloadPage();">
	  <option value="0">Select a subject</option>
<%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() ==0)
	strTemp = "0";
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_from").length() > 0){

strTemp = " from curriculum join course_offered on (curriculum.course_index=course_offered.course_index) "+
		  "left join major on (curriculum.major_index=major.major_index) join college on (course_offered.c_index=college.c_index) "+
		  "join subject on (curriculum.sub_index = subject.sub_index) join e_sub_section on (curriculum.cur_index=e_sub_section.cur_index) "+
		  "where curriculum.is_valid=1 and curriculum.is_del=0 and semester="+request.getParameter("semester")+
		  " and course_offered.c_index="+strTemp+" and e_sub_section.OFFERING_SY_FROM="+request.getParameter("sy_from")+
		  " and OFFERING_SY_TO="+request.getParameter("sy_to")+" and e_sub_section.is_valid=1 and e_sub_section.is_del=0";
//System.out.println(strTemp);

%>
<%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("sub_code"), false)%>
<%}%>
        </select> </td>
      <td>
<%
if(WI.fillTextValue("sub_code").length() > 0 && WI.fillTextValue("sub_code").compareTo("0") != 0){
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() ==0)
	strTemp = "0";
//get here subject section information detail .
strTemp = " from curriculum join course_offered on (curriculum.course_index=course_offered.course_index) "+
	"left join major on (curriculum.major_index=major.major_index) join college on (course_offered.c_index=college.c_index) "+
	"join subject on (curriculum.sub_index = subject.sub_index) join e_sub_section on (curriculum.cur_index=e_sub_section.cur_index) "+
	"where curriculum.is_valid=1 and curriculum.is_del=0 and semester="+request.getParameter("semester")+
	" and course_offered.c_index="+strTemp+" and e_sub_section.OFFERING_SY_FROM="+request.getParameter("sy_from")+
	" and OFFERING_SY_TO="+request.getParameter("sy_to")+" and subject.sub_index="+request.getParameter("sub_code")+
	" and e_sub_section.is_valid=1 and e_sub_section.is_del=0";

%>    <select name="sub_section" onChange="ReloadPage();">
	<option value="0">Select a section</option>
<%=dbOP.loadCombo("SUB_SEC_INDEX","section",strTemp, request.getParameter("sub_section"), false)%>
        </select>
<%}%>
</td>
      <td>
<%
if(WI.fillTextValue("sub_code").length() > 0)
{
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("sub_code"),"sub_name"," and is_del=0");
	if(strTemp == null) strTemp = "";
%>	   <%=strTemp%></td>
<%}%>
    </tr>
  </table>
<%
if(vSectionDetail != null){%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25" >&nbsp;</td>
      <td width="39%">Subject Schedule (MWF Format)</td>
      <td width="30%">Instructor</td>
      <td width="20%"></td>
      <td width="10%"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td> <%=vSectionDetail.elementAt(0)%></td>
      <td>
        <%for(int i=1; i<vSectionDetail.size(); ++i){%>
        <%=vSectionDetail.elementAt(i++)+" "%>
        <%}%>
      </td>
      <td colspan="2" ><input type="image" src="../../../images/view.gif">
        <font size="1"> Click to view/edit grades created</font></td>
    </tr>
    <tr >
      <td height="25" colspan="5"><div align="right">
	  <a href="javascript:PageAction(0);"><img src="../../../images/print.gif" border="0"></a></div></td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF STUDENTS ENROLLED
          IN THIS SUBJECT</div></td>
    </tr>
  </table>
<%
//this is the time when i will get the list of students having no grades yets for the grade term.
Vector vStudList = GS.getGradeSheetEditInfo(dbOP,request);
if(vStudList == null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
	<td width="2%" height="25"></td>
	<td><%=strErrMsg%></td>
	</tr>
</table>
<%}else{%>

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
   <tr>
      <td width="11%"  height="25" ><div align="center"><font size="1"><strong>STUDENT
          ID </strong></font></div></td>
      <td width="15%" ><div align="center"><font size="1"><strong>STUDENT NAME
          </strong></font></div></td>
      <td width="28%" ><div align="center"><font size="1"><strong>COURSE</strong></font></div></td>
      <td width="4%" ><div align="center"><font size="1"><strong>YEAR</strong></font></div></td>
      <td width="25%" ><div align="center"><font size="1"><strong>DATE : TIME</strong></font></div></td>
      <td width="5%" ><div align="center"><font size="1"><strong>F.GRADE</strong></font></div></td>
      <td width="6%" ><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
	  <td width="6%" ><div align="center"><font size="1"><strong>EDIT</strong></font></div></td>
    </tr>
    <%
int j=0;
for(int i=0; i<vStudList.size(); ++i,++j){%>
    <tr>
      <td  height="25" ><font size="1"><%=(String)vStudList.elementAt(i+4)%></font></td>
      <td ><font size="1"><%=(String)vStudList.elementAt(i+3)%></font></td>
      <td ><font size="1"><%=(String)vStudList.elementAt(i+5)%></font></td>
      <td ><font size="1"><%=(String)vStudList.elementAt(i+6)%></font></td>
      <td align="center"><input name="date<%=j%>" type="text" size="10"value="<%=(String)vStudList.elementAt(i+1)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        :
        <input name="time<%=j%>" type="text" size="8"value="<%=(String)vStudList.elementAt(i+7)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="grade<%=j%>" type="text" size="3" value="<%=(String)vStudList.elementAt(i+8)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td ><div align="center">
          <select name="remark<%=j%>">
            <%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0",(String)vStudList.elementAt(i+2) , false)%>
          </select>
        </div></td>
      <td >
<%if(iAccessLevel > 1){%>
	  <input type="image" src="../../../images/edit.gif" onClick='EditRecord("<%=(String)vStudList.elementAt(i)%>","<%=j%>");'>
<%}%>	  </td>
    </tr>
    <%
i = i+8;
}
%>
    <input type="hidden" name="total_grade_count" value="<%=j%>">
  </table>

<%		}//only if vStudList is not null -- there are students having empty grades.
	} //only if vSectionDetail is not null
}//only if school year from/ to is entered.
%>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
          </tr>
  </table>
<input type="hidden" name="page_action"><!-- 0 = print, 1 edit -->
<input type="hidden" name="info_index">
<input type="hidden" name="edit_ref">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
