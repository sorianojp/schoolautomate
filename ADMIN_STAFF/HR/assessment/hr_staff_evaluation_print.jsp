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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_staff_evaluation.jsp");
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
//end authorization

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center">
			<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br><br>
			STAFF PERFORMANCE EVALUATION
		</td>
	</tr>
</table> 
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td colspan="3" class="thinborder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td height="40" width="34%" valign="top">Name(Last)<br><strong>TEST</strong></td>
					<td width="26%" valign="top">(First)<br><strong>TEST</strong></td>
					<td width="40%" valign="top">(M.I.)<br><strong>TEST</strong></td>
				</tr>
			</table>
		</td>
		<td valign="top" width="21%" class="thinborder">Position:<br>
	    <strong>TEST</strong></td>
	</tr>
	<tr>
		<td width="22%" class="thinborder">Performance Period:<br>
	    <strong>TEST</strong></td>
		<td width="20%" class="thinborder">Discussion Date:<br>
	    <strong>TEST</strong></td>
		<td width="37%" class="thinborder">Name and Title of Supervisor:<br>
	    <strong>TEST</strong></td>
		<td class="thinborder">Department:<br><strong>TEST</strong></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td class="thinborderBOTTOM" colspan="5" style="padding-left:30px;"><strong>PERFORMANCE FACTOR RATING SCALE</strong></td></tr>
	<tr>
		<td class="thinborder" valign="top" width="20%" align="center">0<br>
			Below<br>
			Minimum<br>
			Standards
		</td>
		<td class="thinborder" valign="top" width="20%" align="center">
		1<br>
		Does Not<br>
		Consistently<br>
		Meets Standards
		</td>
		<td class="thinborder" valign="top" width="20%" align="center">
		2<br>
		Fully Meets<br>
		Requirements<br>
		</td>
		<td class="thinborder" valign="top" width="20%" align="center">
		3<br>
		Frequently Exceeds<br>
		Requirements
		</td>
		<td class="thinborderBOTTOMLEFTRIGHT" valign="top" width="20%" align="center">
		4<br>
		Consistently Exceeds the<br>
		Requirements
		</td>
	</tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;"><strong>PERFORMANCE FACTORS</strong></td>
		<td width="12%" class="thinborder" style="padding-left:10px;"><strong>Rating</strong></td>
	</tr>
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;"><strong>I. JOB KNOWLEDGE</strong></td>
		<td style="padding-left:10px;" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;">1.Demonstrate understanding of concepts, methods, principles necessary to accomplish job duties.</td>
		<td style="padding-left:10px;" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;">2.Follow policies/protocols in carrying out job responsibilities.</td>
		<td style="padding-left:10px;" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;">3.Respond correctly to inquiries; consults with others as appropriate.</td>
		<td style="padding-left:10px;" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
		<td height="30" colspan="3" valign="top" class="thinborder" style="padding-left:10px;padding-top:3px;"><strong>DOCUMENTATION/COMMENTS</strong></td>
		<td valign="top" style="padding-left:10px;padding-top:3px;" class="thinborder"><strong>TOTAL</strong></td>
	</tr>
	<tr>
	    <td height="18" colspan="3" class="thinborder" style="padding-left:10px;"><strong>TOTAL PERFORMANCE</strong></td>
	    <td style="padding-left:10px;" class="thinborder">&nbsp;</td>
    </tr>
	<tr>
	    <td width="34%" rowspan="5" valign="top" class="thinborder" style="padding-left:10px;">
		TRAINING/DEVELOPMENT RECOMMENDATIONS:<br>
		<br><br>
		EVALUATOR:__________________<br><br><br>
		Date:________________________
		</td>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;"><strong>Points</strong></td>
	    <td width="27%" class="thinborder" style="padding-left:10px;"><strong>Percentage</strong></td>
	    <td style="padding-left:10px;" class="thinborder"><strong>Adjectival Rating</strong></td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">77-96</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">91-100%</td>
	    <td style="padding-left:10px;" class="thinborder">Excellent</td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">59-76</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">82-90%</td>
	    <td style="padding-left:10px;" class="thinborder">Very Satisfactory</td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">45-58</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">75-81%</td>
	    <td style="padding-left:10px;" class="thinborder">Satisfactory</td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">31-44</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">68-74%</td>
	    <td style="padding-left:10px;" class="thinborder">Unsatisfactory</td>
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
