<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	Vector vRetResult  = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","udmc_orusage.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"udmc_orusage.jsp");
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
DailyCashCollection dc = new DailyCashCollection();
if(WI.fillTextValue("date_of_col").length() > 0) {
	vRetResult = dc.getORUsage(dbOP, request);
	if(vRetResult == null)
		strErrMsg = dc.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
int iORPerColumn = 0;//Integer.parseInt(WI.getStrValue(WI.fillTextValue("or_percolumn"),"25"));
int iMaxColumn   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_column"),"5"));

if(vRetResult != null && vRetResult.size() > 0) 
	iORPerColumn = vRetResult.size() / iMaxColumn + 1;
%>

<form name="daily_cash" method="post" action="./udmc_orusage.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DAILY CASHIER'S REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
<%if(WI.fillTextValue("or_range").length() > 0) {//show for OR Range%>
    
<%}else{//show date range.%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><!--Number of OR per Column : 

	  <select name="or_percolumn">
	<%
	for(int i = 25; i < 51; ++i) {
		if(iORPerColumn == i)
			strTemp = " selected";
		else
			strTemp = "";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option> 
    <%}%>
		</select>
	&nbsp;&nbsp;-->
	Max number of column : 
	  <select name="select">
        <%
	for(int i = 5; i < 11; ++i) {
		if(iMaxColumn == i)
			strTemp = " selected";
		else
			strTemp = "";
		%>
	    <option value="<%=i%>"<%=strTemp%>><%=i%></option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">Collection Date</td>
      <td height="25" colspan="3"><font size="1"> 
<%
strTemp = WI.fillTextValue("date_of_col");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
       <input name="date_of_col" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 

<%if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") ) {%>        
		to 
<%
strTemp = WI.fillTextValue("date_of_col_to");
%>
       <input name="date_of_col_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
		(for one day, leave to field empty.)
<%}//show date to only for CGH
%>		</font></td>
    </tr>
 <%}//end of showing date range condition.%>
    <tr> 
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" class="thinborderBOTTOM">Teller ID</td>
      <td width="16%" height="25" class="thinborderBOTTOM"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="41%" class="thinborderBOTTOM">&nbsp;&nbsp;&nbsp;<input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage();">      </td>
      <td width="26%" class="thinborderBOTTOM">&nbsp;
<%if(vRetResult != null) {%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print</font>
<%}%>	  </td>
    </tr>
  </table>
  
<!------------------- display report here ------------------------->  
<%if(vRetResult != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="20" colspan="3" valign="top"><div align="center"><strong>OR USAGE  REPORT </strong></div></td>
    </tr>
    <tr> 
      <td width="35%" height="24" class="thinborderBOTTOM"><font size="1">RUN DATE : <%=WI.getTodaysDateTime()%></font></td>
      <td width="42%" height="24" class="thinborderBOTTOM"><font size="1">Collection Date : 
	  <%=WI.fillTextValue("date_of_col") + WI.getStrValue(WI.fillTextValue("date_of_col_to"), " to ", "", "")%>
	  </font></td>
      <td width="23%" align="right" class="thinborderBOTTOM">&nbsp;<font size="1">
	  <%if(WI.fillTextValue("emp_id").length() > 0) {%>Teller ID #:<%=WI.fillTextValue("emp_id")%><%}%></font>&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
	 <%for(int i = 0, p = 3; i < iMaxColumn; ++i){%>
      <td valign="top">
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	  		<%for( int iRowCount = 0; p < vRetResult.size(); ++p, ++iRowCount) {%>
				<tr><td><%=vRetResult.elementAt(p)%></td></tr>
			<%  if(iRowCount == iORPerColumn) { 
					++p;
					break;
				}
			}%>
	  </table>
	  </td>
	 <%}//end of dynamic column.%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
    </tr>
    <tr> 
	  <td width="25%" align="right" style="font-size:14px;">
		Total Cash  : <br>
		Total Check :  <br>
		Total Collection :       </td>
		<td width="25%" align="right" style="font-size:14px;">
		<%=vRetResult.remove(1)%><br>
		<%=vRetResult.remove(1)%><br>
		<%=vRetResult.remove(0)%>		</td>
		<td width="50%">&nbsp;</td>
	</tr>
  </table>
<%}//////////////////// end of report ////////////////////%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="or_range" value="<%=WI.fillTextValue("or_range")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>