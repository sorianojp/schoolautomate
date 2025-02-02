<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./transmittal_report_print.jsp" />
	<%
	return;}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transmittal Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation();
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
	
	Vector vRetResult = null;
	BankPosting bp = new BankPosting();
	if(WI.fillTextValue("print_page").length() > 0){
		vRetResult = bp.generateTransmittalReport(dbOP, request);
		if(vRetResult == null)
			strErrMsg = bp.getErrMsg();
		else{%>
			<jsp:forward page="./transmittal_report_print.jsp" />
		<%
			return;
		}
	}
%>
<body bgcolor="#D2AE72">
<form action="transmittal_report.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: TRANSMITTAL REPORT ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="17%">Transaction Range: </td>
      <td width="80%">
	  		<input name="transaction_date" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("transaction_date")%>" size="10" readonly="yes">
        	<a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1"> <img src="../../../images/calendar_new.gif" border="0"></a>
					 to 
	  		<input name="trans_date_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("trans_date_to")%>" size="10" readonly="yes">
        	<a href="javascript:show_calendar('form_.trans_date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1"> <img src="../../../images/calendar_new.gif" border="0"></a>
					 
			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College:</td>
      <td><select name="college">
          <option value="0">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_del = 0 order by c_name",WI.fillTextValue("college"),false)%>
      </select></td>
    </tr>
    <tr>
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
      <td><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> <font size="1">Click to print transmittal report.</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
  </table>
	
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>