<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Violation Information Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
-->
</style>
</head>
<script language="JavaScript">
function PrintPg() {
 	document.bgColor = "#FFFFFF";
    document.getElementById('myADTable1').deleteRow(0);
    document.getElementById('myADTable1').deleteRow(0);
    document.getElementById('myADTable1').deleteRow(0);
    document.getElementById('myADTable1').deleteRow(0);
    document.getElementById('myADTable1').deleteRow(0);
	
    document.getElementById('myADTable2').deleteRow(0);
	
    alert("Click OK to print this page");
 	window.print();//called to remove rows, make bk white and call print.
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.vio_user";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function  FocusID() {
	document.form_.vio_user.focus();
}

</script>
<body bgcolor="#8C9AAA" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strImgFileExt = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Report","vio_info_detail.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Health Monitoring","Report",request.getRemoteAddr(),
														"vio_info_detail.jsp");
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
Vector vBasicInfo = null;Vector vRetResult = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.

//check for add - edit or delete
if(WI.fillTextValue("vio_user").length() > 0) {
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("vio_user"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		request.setAttribute("emp_id",request.getParameter("vio_user"));
		vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
		if(vBasicInfo != null)
			bolIsStaff = true;
	}
	else {//check if student is currently enrolled
		Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("vio_user"),
		(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
		if(vTempBasicInfo != null)
			bolIsStudEnrolled = true;
	}
	if(vBasicInfo == null)
		strErrMsg = OAdm.getErrMsg();
}
//gets health info.
if(vBasicInfo!= null) {
	iCafe.Violation vio = new iCafe.Violation();
	vRetResult = vio.viewVioForOneUser(dbOP, WI.fillTextValue("vio_user"));
	if(vRetResult == null)
		strErrMsg = vio.getErrMsg();
}
%>
<form method="post" name="form_" action="./vio_info_detail.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr > 
      <td height="28" colspan="4" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          COMPLETE VIOLATION RECORD ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr > 
      <td width="2%"  >&nbsp;</td>
      <td width="13%" >Enter ID No. :</td>
      <td width="13%" ><input name="vio_user" type="text" size="16" value="<%=WI.fillTextValue("vio_user")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
      <td width="72%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a></td>
    </tr>
    <tr > 
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td ><input type="image" src="../../../images/form_proceed.gif"></td>
      <td >&nbsp;</td>
    </tr>
    <tr > 
      <td height="18" colspan="4" ><hr size="1"></td>
    </tr>
  </table>
<%
if(vBasicInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(!bolIsStaff){%>
    <tr > 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="18%" >Student Name</td>
      <td width="55%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%> ::: <%=WI.fillTextValue("vio_user")%></td>
      <td width="25%" rowspan="3" valign="top" align="left"> <%if(strImgFileExt != null){%> <table bgcolor="#000000">
          <tr bgcolor="#FFFFFF"> 
            <td> <img src="../../../upload_img/<%=WI.fillTextValue("vio_user").toUpperCase()%>.<%=strImgFileExt%>" width="85" height="85"> 
            </td>
          </tr>
        </table>
        <%}%> </td>
    </tr>
    <tr> 
      <td   height="25">&nbsp;</td>
      <td >Status</td>
      <td height="25" > <%if(bolIsStudEnrolled){%>
        Currently Enrolled 
        <%}else{%>
        Not Currently Enrolled 
        <%}%> </td>
    </tr>
    <tr> 
      <td   height="25">&nbsp;</td>
      <td >Year</td>
      <td height="25" ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Course/Major</td>
      <td colspan="2" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <%}//if not staff
else{%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Emp. Name</td>
      <td ><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></td>
      <td rowspan="3" valign="top" align="left"> <%if(strImgFileExt != null){%> <img src="../../../upload_img/<%=WI.fillTextValue("vio_user").toUpperCase()%>.<%=strImgFileExt%>" width="85" height="85" border="1"> 
        <%}%></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Emp. Status</td>
      <td ><%=(String)vBasicInfo.elementAt(16)%> </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Designation</td>
      <td ><%=(String)vBasicInfo.elementAt(15)%></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >College/Office</td>
      <td colspan="2" ><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/ <%=WI.getStrValue(vBasicInfo.elementAt(14))%></td>
    </tr>
    <%}//only if staff %>
  </table>
<%}///only if vBasicInfo is not null

if(vRetResult != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="23" colspan="2"><div align="right"><font color="#0000FF"></font></div></td>
      <td height="23" colspan="3"><div align="right">
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>Print 
          Page &nbsp;&nbsp;</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F"> 
      <td height="23" colspan="2" class="thinborderBOTTOMLEFT"><div align="right"><font color="#0000FF"><strong>VIOLATION 
          RECORDED</strong></font></div></td>
      <td height="23" colspan="3" class="thinborderBOTTOMRIGHT"><div align="right">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</div></td>
    </tr>
    <tr> 
      <td width="5%" height="23" class="thinborder"><font size="1"><strong> TYPE</strong></font></td>
      <td width="55%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>DATE 
          : TIME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>ATTENDANT</strong></font></div></td>
      <td width="15%" class="thinborder" align="center"><font size="1"><strong>I-BLOCK 
        DATE</strong></font></td>
    </tr>
    <%
String[] astrConvertType = {"Low","Medium","High","Very High"};	
for(int i = 0; i < vRetResult.size() ; i += 10){%>
    <tr> 
      <td class="thinborder"><%=astrConvertType[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%> ::: <%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 4)))%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)+ "<br><font size=1>"+(String)vRetResult.elementAt(i + 9)+"</font>"%></td>
      <td class="thinborder"> <%if( vRetResult.elementAt(i + 6) != null) {%> <%=(String)vRetResult.elementAt(i + 6)%> to <%=(String)vRetResult.elementAt(i + 7)%> <%}else{%> &nbsp; <%}%> </td>
    </tr>
    <%}//end of for loop%>
  </table>
  <%}%>
  
  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
