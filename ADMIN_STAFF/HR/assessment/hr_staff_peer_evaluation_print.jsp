<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

</script>
<body>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_staff_evaluation.jsp");
		
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.


%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center">			
			PEER EVALUATION FOR NON-TEACHING PERSONNEL
		</td>
	</tr>
</table> 
<br>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="35" valign="bottom" width="15%">NAME OF PEER:</td>
		<td valign="bottom" width="40%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong>TEST</strong></div></td>
		<td valign="bottom" width="13%">Position:</td>
		<td valign="bottom" width="32%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong>TEST</strong></div></td>
	</tr>
	<tr>
		<td height="35" valign="bottom" width="15%">Period Covered:</td>
		<td valign="bottom" width="40%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong>TEST</strong></div></td>
		<td valign="bottom" width="13%">Date Evaluated:</td>
		<td valign="bottom" width="32%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong>TEST</strong></div></td>
	</tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="15%">DIRECTION:</td>
		<td colspan="4">Please encircle the number corresponding to your perception of an observable 
			behavior of your peer. The descriptive ratings are as follows:</td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td width="7%">&nbsp;</td>
        <td width="24%">&nbsp;</td>
        <td width="6%">&nbsp;</td>
        <td width="48%">&nbsp;</td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td>5</td>
        <td>Excellent</td>
        <td>2</td>
        <td>Fair</td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td>4</td>
        <td>Very Good</td>
        <td>1</td>
        <td>Poor</td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td>3</td>
        <td>Good</td>
        <td>NA</td>
        <td>Not Applicable</td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>(Should the item be unobservable)</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="8"><strong>A. PERSONALITY</strong></td></tr>
	<tr>
		<td height="17" width="4%" align="right">1.&nbsp;</td>
		<td>Maintains good relations with peers</td>
		<td width="3%" align="center">5</td>
		<td width="3%" align="center">4</td>
		<td width="3%" align="center">3</td>
		<td width="3%" align="center">2</td>
		<td width="3%" align="center">1</td>
		<td width="3%" align="center">N/A</td>
	</tr>
	<tr>
	    <td height="17" align="right">2.&nbsp;</td>
	    <td>Works to achieve good relationship with faculty members and students.</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">3.&nbsp;</td>
	    <td>Is subtle in disagreeing with the opinion of others.</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">4.&nbsp;</td>
	    <td>Is courteous to all members of the group.</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">5.&nbsp;</td>
	    <td>Accepts criticism in good spirit</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">6.&nbsp;</td>
	    <td>Respects ideas.</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">7.&nbsp;</td>
	    <td>Respects ideas of others.</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">8.&nbsp;</td>
	    <td>Self-reliant/independent-minded</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">9.&nbsp;</td>
	    <td>Has healthy attitude towards problems.</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
	<tr>
	    <td height="17" align="right">10.&nbsp;</td>
	    <td>Observes moral standards of behavior.</td>
	    <td align="center">5</td>
	    <td align="center">4</td>
	    <td align="center">3</td>
	    <td align="center">2</td>
	    <td align="center">1</td>
	    <td align="center">N/A</td>
    </tr>
</table>


<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>Form ID</td>
		<td>: HRD 0011</td>
	</tr>
	<tr>
		<td>Rev. No.</td>
		<td>: 05</td>
	</tr>
	<tr>
		<td>Rev. Date</td>
		<td>: 11/19/07</td>
	</tr>
</table>
</div>
</body>
</html>
<%
	dbOP.cleanUP();
%>
