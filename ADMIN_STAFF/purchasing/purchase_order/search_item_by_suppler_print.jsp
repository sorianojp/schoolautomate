<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();		
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="window.print()">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;


//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-PURCHASE ORDER-Approved Requests","search_item_by_suppler.jsp");
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
		
	Requisition REQ = new Requisition();
	PO PO = new PO();
	Vector vRetResult = null;
	boolean bolLooped = false;
	boolean bolPageBreak  = false;
	int iLoop = 0;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	vRetResult = PO.searchItemBySupplier(dbOP,request);
	int iPageTotal = 0;
	int iPage = 1;
		
	if(vRetResult != null ){
	iPageTotal = vRetResult.size()/(8*iMaxStudPerPage);
	if(vRetResult.size() % (8*iMaxStudPerPage) > 0)
		iPageTotal++;
		
	for(;iLoop < vRetResult.size();iPage++){
		bolLooped = false;		
%>
<form name="form_" method="post" action="search_item_by_suppler.jsp">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>    
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2"><div align="right"><font size="1">Page <%=iPage%> of <%=iPageTotal%></font></div></td>
    </tr>
    <tr> 
      <td width="100%" height="25" colspan="2" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#000000"><strong>LIST 
          OF PURCHASED ITEM(S) PER SUPPLIER</strong></font></div></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="23%" height="27" rowspan="2" class="thinborder"><div align="center"><strong>SUPPLIER</strong></div></td>
      <td width="51%" rowspan="2" class="thinborder"><div align="center"><strong>ITEM 
          / BRAND</strong></div></td>
      <td width="9%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">FREQUENCY</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">LAST PURCHASE</font></strong></div></td>
    </tr>
    <tr>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">PRICE</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">DATE</font></strong></div></td>
    </tr>
    <% 
	for(int iCount = 0;iLoop < vRetResult.size();iLoop+=8, iCount++){
		if (iCount >= iMaxStudPerPage || iLoop >= vRetResult.size()){
		if(iLoop >= vRetResult.size())
			bolPageBreak = false;
		else
			bolPageBreak = true;
		break;		
	}%>
    <tr> 
      <td height="20" valign="top" class="thinborder"><div align="left"><font size="1"> 
          &nbsp; 
          <%
		  if (bolLooped && ((String)vRetResult.elementAt(iLoop)).equals((String)vRetResult.elementAt(iLoop-8))){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(iLoop)%> 
          <%}%>
          </font></div></td>
      <td valign="top" class="thinborder"><FONT size="1">&nbsp;<%=(String)vRetResult.elementAt(iLoop+2)%><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+1),"(",")","&nbsp;")%></FONT></td>
	  <td valign="top" class="thinborder"><div align="right"><FONT size="1"><%=(String)vRetResult.elementAt(iLoop+6)%>&nbsp;</FONT></div></td>
	  <td valign="top" class="thinborder"><div align="right"><FONT size="1"><%=(String)vRetResult.elementAt(iLoop+7)%>&nbsp;</FONT></div></td>
      <td valign="top" class="thinborder"><div align="right"><FONT size="1"><%=(String)vRetResult.elementAt(iLoop+3)%>&nbsp;</FONT></div></td>
    </tr>
    <%
		bolLooped = true;
	}%>
    <%if (iLoop >= vRetResult.size()){	
    %>
    <tr> 
      <td class="thinborder" colspan="8" ><div align="center"><font size="1"> 
          ~~~~ NOTHING FOLLOWS ~~~~</font></div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td class="thinborder" colspan="8" ><div align="center"><font size="1"> 
          ~~~~ CONTINUED ON NEXT PAGE ~~~~</font></div></td>
    </tr>
    <%}%>
  </table>  
  <%}%>
    <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }
	}
	%>
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>