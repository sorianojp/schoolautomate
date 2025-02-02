<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage() {
	document.form_.submit();
}
</script>
<script src="../../../jscript/common.js"></script>
<%@ page language="java" import="utility.*,lms.CirculationReport,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation","collection_usage_summary.jsp");
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


//end of authenticaion code.
CirculationReport cReport = new CirculationReport();
Vector vRetResult = null;
if(WI.fillTextValue("search_").length() > 0) {
	//search here. 
	vRetResult = cReport.overdueSummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = cReport.getErrMsg();
}

java.sql.ResultSet rs = null;
%>
<body bgcolor="#D0E19D" topmargin="0" bottommargin="0">
<form action="./collection_usage_summary.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="5" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION : REPORTS : COLLECTION USAGE SUMMARY PAGE ::::</strong></font></div></td>
    </tr>
    <tr valign="top"> 
      <td height="25" colspan="5"><a href="reports_main.jsp"><img src="../../images/goback_circulation.gif" width="54" height="29" border="0"></a></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2">Report Circulation(s) for </td>
      <td width="21%">Year</td>
      <td width="41%">Month </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("report_type");
if(strTemp.equals("0") || request.getParameter("report_type") == null)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  	<input type="radio" name="report_type" value="0"<%=strErrMsg%> onClick="ReloadPage();"> DDC 
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
<!--	  	<input type="radio" name="report_type" value="1"<%=strErrMsg%> onClick="ReloadPage();">LC	-->	
	  </td>
      <td>
<%
strTemp = WI.fillTextValue("year_of");
if(strTemp.length() == 0) {
	strTemp = WI.getTodaysDate();
	strTemp = strTemp.substring(0,4);
}%>
		  <input name="year_of" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"
		onKeyUp="AllowOnlyInteger('form_','year_of');"></td>
      <td>
	    <select name="month_of">
			<%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
if(WI.fillTextValue("report_type").length() == 0 || WI.fillTextValue("report_type").equals("0")){%>
	  From 
	  	<input name="ddc_fr" type="text" size="3" maxlength="3" value="<%=WI.getStrValue(WI.fillTextValue("ddc_fr"),"000")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','ddc_fr');style.backgroundColor='white'"
		onKeyup="AllowOnlyInteger('form_','ddc_fr');">
      		to 
	  	<input name="ddc_to" type="text" size="3" maxlength="3" value="<%=WI.getStrValue(WI.fillTextValue("ddc_to"),"999")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','ddc_to');style.backgroundColor='white'"
		onKeyup="AllowOnlyInteger('form_','ddc_to');">
		      in 
<%
strTemp = WI.fillTextValue("ddc_in_size");
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
      	<input type="radio" name="ddc_in_size" value="1"<%=strErrMsg%>>1's 
<%
if(strTemp.equals("10"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="ddc_in_size" value="10"<%=strErrMsg%>>10's 
<%
if(strTemp.equals("100") || request.getParameter("ddc_in_size") == null)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="ddc_in_size" value="100"<%=strErrMsg%>>100's 
<%}else {//show LC otherwise.%>	 
	From : 
        <select name="select4">
          <option>A</option>
          <option>B</option>
          <option>C</option>
          <option>D</option>
          <option>E</option>
          <option>F</option>
          <option>Z</option>
        </select> 
        to 
        <select name="select5">
          <option>A</option>
          <option>B</option>
          <option>C</option>
          <option>D</option>
          <option>E</option>
          <option>F</option>
          <option>Z</option>
        </select>
<%}%>		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="6%"><div align="right">
          <input type="checkbox" name="checkbox4" value="checkbox">
        </div></td>
      <td colspan="3">Include Call Number(s) not starting with DDC Numbers or the LC letter group</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="29%">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="submit" name="1" value="&nbsp; Search &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td></td>
      <td>&nbsp;</td>
      <td><div align="right"><img src="../../../../lms_redesigned/images/print_circulation.gif" width="60" height="29"><font size="1">click 
          to print report</font></div></td>
    </tr>
    <tr bgcolor="#4BBA45"> 
      <td height="25" colspan="5"> <div align="center"><font color="#FFFFFF">COLLECTION 
          USAGE SUMMARY </font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="17%" height="35"><div align="center"><strong><font size="1">RANGE</font></strong></div></td>
      <td width="23%"><div align="center"><strong>TOTAL COLLECTION</strong></div></td>
      <td width="20%"><div align="center"><strong>TOTAL CIRCULATION</strong></div></td>
      <td width="20%" height="35"><div align="center"><strong>YEARLY CIRCULATION</strong></div></td>
      <td width="20%" height="35"><div align="center"><strong>MONTHLY CIRCULATION</strong></div></td>
    </tr>
    <tr> 
      <td height="25"><div align="center">000 - 099</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"><strong>TOTAL</strong></font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>