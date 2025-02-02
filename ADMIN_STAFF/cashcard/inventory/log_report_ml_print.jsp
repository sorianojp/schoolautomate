<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Untitled Document</title>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	 	
//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory-Manage Item Master List","inventory_log_ml.jsp");
	}catch(Exception exp){	
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"CASH CARD","Inventory",request.getRemoteAddr(),
														"inventory_log_ml.jsp");
	
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


int i =0;
Vector vRetResult = null;
RestItems restItems = new RestItems();


	vRetResult = restItems.operateOnInventoryReport(dbOP, request, 1);
	if(vRetResult == null)
		strErrMsg = restItems.getErrMsg();



%>
<body onload="window.print();">



<%if(vRetResult != null && vRetResult.size() > 0){


boolean bolIsPageBreak = false;
int iResultSize = 12;
int iLineCount = 0;
int iMaxLineCount = 30;	

while(iResultSize <= vRetResult.size()){
iLineCount = 0;


%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center"><font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td></tr>
	<tr><td align="center" height="20"><strong>MAIN INVENTORY LOG REPORT <br><%=WI.getStrValue(WI.fillTextValue("date_fr"))%><%=WI.getStrValue(WI.fillTextValue("date_to"),"-","","")%></strong><br></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="10%" height="25" class="thinborder" align="center"><b>CATEGORY</b></td>
    <td width="10%" class="thinborder" align="center"><b>ITEM CODE </b></td>
    <td width=""    class="thinborder" align="center"><b>ITEM NAME </b></td>
    <td width="10%" class="thinborder" align="center"><b>PURCHASE UNIT </b></td>
    <td width="10%" class="thinborder" align="center"><b>SELLING  UNIT </b></td>
    <td width="5%"  class="thinborder" align="center"><b>CONVERSION</b></td>
    <td width="5%"  class="thinborder" align="center"><b>SELLING PRICE </b></td>
	<td width="5%"  class="thinborder" align="center"><b>LOG QTY</b></td>
    <td width="10%" class="thinborder" align="center"><b>LOGGED BY</b></td>
	<td width="12%" class="thinborder" align="center"><b>LOGGED DATE</b></td>
  </tr>
  <%	for(; i < vRetResult.size();){			
			iLineCount++;		
			iResultSize += 12;	%>
	<tr>
    <td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"n/a")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"n/a")%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+7)%>&nbsp;</td>
	<%
	strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10),(String)vRetResult.elementAt(i+11),4);
	%>
	<td class="thinborder"><%=strTemp%></td>
	<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
    </tr>
	
		<%
			i+=12;
			if(iLineCount >= iMaxLineCount){
				bolIsPageBreak = true;
				break;		
			}else
				bolIsPageBreak = false;	
		%>
	
	<%}%>
</table>


	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>

<%}
}%>

</body>
</html>
<%
dbOP.cleanUP();
%>