<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Exam Result Encoding </title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{

	document.form_.show_list.value ="1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_page").compareTo("1") == 0){%>

		<jsp:forward page="./view_applicant_enrichment_print.jsp"/>

<%return;}

	Vector vRetResult = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;
	int iCount = 0;
	int iCount2 = 1;

	String[] astrRemarks = {"Failed","Passed"};
	int iEncoded = 1;
	String strSchCode  = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW",
								"view_applicant_enrichment.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",
														request.getRemoteAddr(),"view_applicant_enrichment.jsp");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	if (WI.fillTextValue("show_list").equals("1")){
		vRetResult = appMgmt.generatePerGroup(dbOP, request);
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_applicant_enrichment.jsp" method="post">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
      <font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif" ><strong>:::: QUALIFIED APPLICANTS PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr>
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="20%">School Year / Term</td>
      <td colspan="2"> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
	<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
    <select name="semester">
          <%
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
          <%}

		  if (!strSchCode.startsWith("CPU")) {

		  if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  %>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>List Option </td>
      <td width="28%">
        <select name="REG_EE_ME">
	      <option value="" selected>ALL</option>
<%
	strTemp = WI.fillTextValue("REG_EE_ME");
	if(strTemp.equals("0")){%>
          <option value="0" selected>Regular</option>
          <%}else{%>
          <option value="0">Regular</option>
          <%}if(strTemp.equals("1")){%>
          <option value="1" selected>English Enrichment</option>
          <%}else{%>
          <option value="1">English Enrichment</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Math Enrichment</option>
          <%}else{%>
          <option value="2">Math Enrichment</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>Math and English Enrichment</option>
          <%}else{%>
          <option value="3">Math and English Enrichment</option>
          <%} %>
        </select></td>
      <td width="46%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:10px;">
<%
strTemp = WI.fillTextValue("show_res");
if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  	<input type="radio" name="show_res" value="0" <%=strErrMsg%>> Show only applicant with reservation <br>
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
		<input type="radio" name="show_res" value="1" <%=strErrMsg%>> Show only applicant without reservation <br>
<%
if(strTemp.equals("2") || strTemp.length() == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
		<input type="radio" name="show_res" value="2" <%=strErrMsg%>> Show all 
	  </td>
    </tr>
  </table>
<%
	if (vRetResult != null) {//System.out.println(vRetResult);
		String[] astrSubj ={"REG","EE","ME","EE and ME","&nbsp;"};

	%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong><font color="#FFFFFF">QUALIFIED APPLICANTS </font></strong></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="17%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="54%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>COURSE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>SUBJECT TO TAKE </strong></td>
    </tr>
<%  for(int t = 0; t < vRetResult.size(); t+=6, iCount++){ %>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount+1%>&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vRetResult.elementAt(t)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vRetResult.elementAt(t+1),(String)vRetResult.elementAt(t+2),
							(String)vRetResult.elementAt(t+3),4)%></td>
      <td class="thinborder">&nbsp;
        <%=(String)vRetResult.elementAt(t + 5)%></td>
      <td align="center" class="thinborder">&nbsp;
  	<%=astrSubj[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(t+4),"4"))]%>	  </td>
    </tr>
    <%}%>
  </table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="45%" height="30" align="right">&nbsp;</td>
      <td width="55%">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" align="right">
	  Number of Applicants Per Page
        <select name="appl_per_page">
          <option>20</option>
          <option>25</option>
          <option>30</option>
          <option>35</option>
          <option>40</option>
          <option>45</option>
          <option>50</option>
        </select>
      &nbsp;</td>
      <td><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print list</font></td>
    </tr>
  </table>
  <%}  %>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="print_page" value="">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
