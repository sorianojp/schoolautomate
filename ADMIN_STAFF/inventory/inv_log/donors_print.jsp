<%@ page language="java" import="utility.*,java.util.Vector,inventory.InventoryDonors" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Donors</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%
//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-DONORS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-DONORS","donors.jsp");
	
	InventoryDonors invDonor = new InventoryDonors();
	Vector vRetDonors = new Vector();
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolPageBreak = false;

	vRetDonors = invDonor.operateOnDonorInfo(dbOP,request,4);
	if (vRetDonors != null) {	
	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));	

	int iNumRec = 0;//System.out.println(vRetDonors);
	int iIncr    = 1;
	int iTotalPages = vRetDonors.size()/(6*iMaxRecPerPage);	
	if(vRetDonors.size() % (6*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetDonors.size();iPage++){	   
%>
<body onLoad="javascript:window.print();">
<form name="form_">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableRow">  
    <tr> 
      <td width="100%" height="35" align="center" bgcolor="#FFFFFF" class="thinborderTOPLEFTRIGHT"><font color="#000000"><strong>LIST 
      OF DONORS</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td width="24%" height="19" align="center" class="thinborder"><strong>DONOR 
          NAME</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>TYPE</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>CONTACT NOS.</strong></td>
      <td width="27%" align="center" class="thinborder"><strong>CONTACT PERSON</strong></td>
    </tr>
	<% 
		for(iCount = 1; iNumRec<vRetDonors.size(); iNumRec+=6,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>  		
    <tr> 
      <td height="20" class="thinborder">&nbsp;<%=(String)vRetDonors.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetDonors.elementAt(i+1)%></td>
			<%
				strTemp = (String)vRetDonors.elementAt(i+4);			
			%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = (String)vRetDonors.elementAt(i+5);			
			%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    </tr>
    <%}// end for loop%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetDonors.size()
} //end end upper most if (vRetDonors !=null)%>
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>
