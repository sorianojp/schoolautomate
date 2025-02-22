<%@ page language="java" import="utility.*,java.util.Vector,purchasing.Supplier,purchasing.Country " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Suppliers</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%
//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-SUPPLIERS"),"0"));
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
	DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-SUPPLIERS-Suppliers","suppliers.jsp");
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
		
	Supplier SUP = new Supplier();
	Vector vRetResult = new Vector();
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPosition = null;
	String[] astrSuppType = {"Individual","Company"};
	String[] astrPhoneType = {"Mobile","Home","Office"};
	boolean bolPageBreak = false;

	vRetResult = SUP.operateOnSupplierInfo(dbOP,request,4);
	if (vRetResult != null) {	
	
	int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_stud_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int i = 0;
	 for (;iNumRec < vRetResult.size();){ 		
%>
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25" class="thinborderTOPLEFTRIGHT"><div align="center"><strong>LIST 
          OF SUPPLIERS</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="6%" align="center" class="thinborder">&nbsp;</td> 
      <td width="15%" height="25" align="center" class="thinborder"><strong>SUPPLIER CODE </strong></td>
      <td width="25%" align="center" class="thinborder"><strong>SUPPLIER NAME</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>TYPE</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>CONTACT NOS.</strong></td>
      <td width="23%" align="center" class="thinborder"><strong>CONTACT PERSON</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>A/P BALANCE</strong></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=26,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			
	  %>		
    <tr>
      <td class="thinborder">&nbsp;<%=iIncr%></td> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				strTemp = astrSuppType[Integer.parseInt(WI.getStrValue(strTemp,"0"))];
			%>
      <td class="thinborder"><%=strTemp%></td>
		<%
				strTemp2 = (String)vRetResult.elementAt(i+7);
				strTemp2 = astrPhoneType[Integer.parseInt(strTemp2)];
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4), strTemp2 + " :<br>","<br>","");
				strTemp2 = (String)vRetResult.elementAt(i+8);
				strTemp2 = astrPhoneType[Integer.parseInt(strTemp2)];
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+5),strTemp2 + " :<br>","<br>","");
				strTemp2 = (String)vRetResult.elementAt(i+9);
				strTemp2 = astrPhoneType[Integer.parseInt(strTemp2)];
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6),strTemp2 + " :<br>","<br>","");
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+10),"Fax :<br>","<br>","");
		%>
      <td class="thinborder"><%=strTemp%></td>
			<%
//            vEditInfo.addElement(WI.getStrValue(rs.getString(13),
//                WI.getStrValue(rs.getString(12),"","&nbsp;",""),
//                WI.getStrValue(rs.getString(14)," <br>(",")",""), ""));//CONTACT_PERSON[5]
				
				strPosition = WI.getStrValue((String)vRetResult.elementAt(i+13),"(",")","");// position
				strTemp = (String)vRetResult.elementAt(i+11); // salutation
				strTemp = WI.getStrValue(strTemp,"","&nbsp;","");
				strTemp2 = (String)vRetResult.elementAt(i+12); // Contact person
				strTemp2 = WI.getStrValue(strTemp2, strTemp, "<br>" +strPosition,"&nbsp;");
				
			%>			
      <td class="thinborder"><%=strTemp2%></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
		<%if (iNumRec >= vRetResult.size()) {%>
		<tr>
      <td height="20" colspan="7" align="center" class="thinborder"><font size="1">~~~~ 
      NOTHING FOLLOWS ~~~~ </font></td>
    </tr>
		<%}else{%>
		<tr>
      <td height="20" colspan="7" align="center" class="thinborder"><font size="1">~~~~ 
      CONTINUED ON NEXT PAGE ~~~~ </font></td>
    </tr>
		<%}%>		
  </table>
  <%if (bolPageBreak){%>
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
