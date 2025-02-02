<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Recompute EDTR Undertime</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","update_ut_special.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"dtr_update_old.jsp");	
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
if(strErrMsg == null) strErrMsg = "";


ReportEDTR RE = new ReportEDTR(request);
int iResult = 0;
String[] astrAMPM = {"AM","PM"};
boolean bolPageBreak = false;
Vector vRetResult = null;
vRetResult = RE.getUndertimeUpdates(dbOP);
	if (vRetResult != null) {	
	int i = 0; 
	int iPage = 1; 
	int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iTotalPages = vRetResult.size()/(9*iMaxRecPerPage);	
	if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){  
%>
<form name="form_">
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>LIST OF UPDATES MADE </strong></td>
    </tr>
    <tr> 
      <td width="15%" height="25" align="center" class="thinborder"><strong>&nbsp;DATE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>Minutes adjusted </strong></td>
      <td width="51%" align="center" class="thinborder"><strong>Reason for adjustment </strong></td>
      <td width="24%" align="center" class="thinborder"><strong>&nbsp;Updated by </strong></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
		%>		
    <tr> 
      <td class="thinborder" height="20">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> - <%=astrAMPM[Integer.parseInt((String)vRetResult.elementAt(i+2))]%></td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+6), 
		 			  		 (String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), 1)%></td>
    </tr>
    <%} // end for loop%>
  </table>
  <%if (iNumRec < vRetResult.size()){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>