<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="window.print()">
<%
//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-QUOTATION","request_requotation_print.jsp");		
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItemsPO = null;	
	String strErrMsg = null;
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String strInfoIndex = WI.fillTextValue("info_index");
	String strSchCode = dbOP.getSchoolIndex();
	int iLoop = 0;
	int iCount = 0;
	
		vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);
		if(vReqInfo != null){
			strInfoIndex = (String)vReqInfo.elementAt(0);//requisition_index
			vRetResult = QTN.getRequestItems(dbOP,request,strInfoIndex);
	
		}				

%>
<form name="form_" method="post">
<%if(vReqInfo != null){// depensa sa error pag mag tinanga ang user%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
<%if(!strSchCode.startsWith("UI")){%>
	<tr> 
	 <td align="center" width="27%"><div align="right">&nbsp;
	  <%if(strSchCode.startsWith("CPU")){%>
	  <img src="../../../images/logo/CPU.gif" width="70" height="70" border="0">
	  <%}%>
	  </div></td>	
    <td height="25" colspan="2" width="46%"><div align="center"> <strong>
	        <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
		  <font size="+2"><strong>CANVASS FORM</strong></font>
		  <br>
          <br>
        </div></td>
	 <td align="center" width="27%"><div align="right">&nbsp;</div></td>		
  </tr>
  <%}else{%>
  	<tr> 
    <td height="25" colspan="4">&nbsp;<br><br><br><br><br></td>
  </tr>
  <%}// if the school code starts with UI %>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Canvassing No.</font></td>
      <td width="26%"><strong><font size="1"><%=vReqInfo.elementAt(1)%></font></strong></td>
      <td width="20%"><font size="1">Canvassing Date </font></td>
      <td width="31%"><strong><font size="1"><%=vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
  </table>
  <br>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="center"><font color="#000000"><strong>LIST 
          OF REQUISITION ITEM(S)</strong></font></div></td>
    </tr>
    <tr> 
      <td width="4%" height="26" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="4%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
      / DESCRIPTION </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>BRAND NAME</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>SUPPLIER 
      CODE </strong></td>
      <td width="16%" align="center" class="thinborder"><strong>PRICE QUOTED</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>DISCOUNT</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>TOTAL AMOUNT</strong></td>
    </tr>
    <%//System.out.println("size " + vRetResult.size());
	for(iLoop = 0,iCount = 0;iLoop < vRetResult.size();iLoop+=11,++iCount){%>
    <tr> 
      <td height="25" align="right" class="thinborder"><%=vRetResult.elementAt(iLoop+1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(iLoop+3)%> 
        / <%=vRetResult.elementAt(iLoop+4)%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount%> 
          <input type="hidden" name="num_of_items" value="<%=iCount%>">
          </strong></div></td>
    </tr>
  </table>
  <!--
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>LIST 
          OF REQUISITION ITEM(S)</strong></div></td>
    </tr>
    <tr>
      <td width="4%" height="26" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS / DESCRIPTION </strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>SUPPLIER CODE </strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>PRICE QUOTED</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
    </tr>
    <%//for(iLoop = 0,iCount = 0;iLoop < vRetResult.size();iLoop+=10,++iCount){%>
    <tr>
      <td height="25" class="thinborder"><div align="center"><%//=vRetResult.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%//=vRetResult.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%//=vRetResult.elementAt(iLoop+3)%> / <%//=vRetResult.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="center">&nbsp;</div></td>
      <td class="thinborder"><div align="right">&nbsp;</div></td>
      <td class="thinborder"><div align="right">&nbsp;</div></td>
      <td class="thinborder"><div align="right">&nbsp;</div></td>
      <td class="thinborder"><div align="right">&nbsp;</div></td>
    </tr>
    <%//}%>
    <tr>
      <td height="25" colspan="8" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%//=iCount%></strong></div></td>
    </tr>
  </table>  
  */
  -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="19%" height="25"><strong>CANVASSED BY : </strong>&nbsp;</td>
      <td width="27%" class="thinborderBottom">&nbsp;</td>
      <td width="54%">&nbsp;</td>
    </tr>
  </table>
  <%}%>
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>