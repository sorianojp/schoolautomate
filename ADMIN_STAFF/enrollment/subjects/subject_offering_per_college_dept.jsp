<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning","subj_sectioning.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintThisPage() {
	var strInfo = "<div align=\"center\"><strong><font size=3><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </font></strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div><br>";
	this.insRowVarTableID('myADTable',0, 1, strInfo);

	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.bgColor = "#FFFFFF";
	alert("Click OK to print this page");
	window.print();
}
function ReloadPage() {
	document.form_.proceed.value = "";
	this.SubmitOnce("form_");
}
function DisplayResult() {
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");	
}
function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
	//alert(strURL);
	this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"subject_offering_per_college_dept.jsp");
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

Vector vRetResult = new Vector();
StatEnrollment SE = new StatEnrollment();
if(WI.fillTextValue("proceed").compareTo("1") ==0)
{
	vRetResult = SE.getSubjectOfferingPerCollege(dbOP,request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";

String strSYFrom = WI.fillTextValue("offering_yr_from");
String strSYTo   = null;
String strSemester = WI.fillTextValue("offering_sem");

if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
strSYTo = String.valueOf(Integer.parseInt(strSYFrom) + 1);

if(strSemester.length() ==0) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");


%>
<form name="form_" action="./subject_offering_per_college_dept.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong> SUBJECTS OFFERING 
          PAGE </strong><strong>FOR AY : <%=strSYFrom%> - <%=strSYTo%>, 
          <%=dbOP.getHETerm(Integer.parseInt(strSemester))%></strong></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td height="25"></td>
      <td colspan="2"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2">School offereing year/term: 
 <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","offering_yr_from");DisplaySYTo("form_","offering_yr_from","offering_yr_to")'>
        to 
<%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; <select name="offering_sem">
	  		<%=CommonUtil.constructTermList(dbOP, request, strSemester)%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" width="2%"></td>
      <td width="12%"><strong>Show By :</strong></td>
      <td width="86%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>College offered</td>
      <td><select name="c_index" onChange="loadDept();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>Department</td>
      <td>
<label id="load_dept">
<%if(WI.fillTextValue("c_index").length() > 0) {%>
	  <select name="d_index">
          <option value=""></option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index = "+WI.fillTextValue("c_index")+" order by d_name asc",WI.fillTextValue("d_index"), false)%>
        </select>
<%}%>
</label>	  
	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2"> Subject: &nbsp;&nbsp;&nbsp; <input type="text" name="scroll_sub" class="textbox"
	     onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');"> 
        <font size="1">(enter subject code to scroll subject)</font> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2"><select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
          <option value="">ALL</option>
<%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 order by s_code",WI.fillTextValue("sub_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td><a href="javascript:DisplayResult();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <%if(vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintThisPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
    <%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr > 
      <td height="25" width="50%" class="thinborderLEFT">&nbsp;&nbsp;TOTAL SUBJECTS 
        OFFERINGS: <%=vRetResult.size()/5%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="12%" height="27" align="center" class="thinborder"><font size="1"><strong>OFFERING COLLEGE</strong></font></td>
      <td width="38%" align="center" class="thinborder"><font size="1"><strong>SUBJECTCODE (DESCRIPTION)</strong></font></td>
      <td width="50%" align="center" class="thinborder"><font size="1"><strong>SECTION 
        ::: SCHEDULE (ROOM #)</strong></font></td>
    </tr>
    <%String strCollegeCode = null;String strCollegeCodeToDisp = null;
 for(int i=0; i< vRetResult.size(); i += 5){
 	if(strCollegeCode == null) {
	 	strCollegeCode = (String)vRetResult.elementAt(i);
		strCollegeCodeToDisp = strCollegeCode;
	}
	else if(strCollegeCode.compareTo((String)vRetResult.elementAt(i)) == 0)
		strCollegeCodeToDisp = " --- \"\" --- ";
	else {
	 	strCollegeCode = (String)vRetResult.elementAt(i);
		strCollegeCodeToDisp = strCollegeCode;
	}	
	
	
	%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=strCollegeCodeToDisp%></div></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>(<%=(String)vRetResult.elementAt(i+2)%>)</td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp;")%>:::<%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
    </tr>
<%}%>
  </table>
<%}//show only if vRetResult is not null%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="proceed"> 
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
