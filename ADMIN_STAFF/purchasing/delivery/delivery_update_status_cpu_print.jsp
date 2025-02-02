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
	font-size: 9px;
}
TD.thinborderBottom {    
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
TD.thinborderLEFT {    
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
TD.tthinborderBOTTOMLEFTRIGHT {    
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;	
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

</style>
</head>
<body onLoad="window.print();s">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_update_status_cpu_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Delivery DEL = new Delivery();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	int iCount = 1;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	String strSchCode = dbOP.getSchoolIndex();	
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"13"));
	int iCountRows = 0;
	int i = 5;
	vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);	
	if(vReqInfo == null)
		strErrMsg = DEL.getErrMsg();
	else{
		vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0),true,"CPU");
		if(vRetResult == null)
			strErrMsg = DEL.getErrMsg();
	}
	if(vRetResult != null)
		for(;i < vRetResult.size();){
		iCountRows = 0;
%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font>
	  </strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <br>
			PROPERTY CUSTODIAN OFFICE<br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="73%" height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26" align="right"><font size="1">Date : </font></td>
      <td width="25%" valign="bottom" class="thinborderBOTTOM"><div align="center"><strong><font size="1">&nbsp;<%=WI.getTodaysDate(6)%></font></strong></div></td>
      <td width="2%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="26" colspan="3" align="center">RECEIVING REPORT</td>
    </tr>
  </table>
  <br>
  <%if(vRetResult!= null && vRetResult.size() > 6){%>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3" height="25" class="thinborder">&nbsp;VENDOR : &nbsp;<strong><%=WI.getStrValue((String)vRetResult.elementAt(1),"&nbsp;")%></strong></td>
      <td height="25" colspan="5" class="thinborder">&nbsp;PO DATE : <strong><%=(String)vRetResult.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" class="thinborder">&nbsp;P.O. NO. &nbsp;<strong><%=(String)vRetResult.elementAt(2)%></strong></td>
      <td colspan="5" class="thinborder">&nbsp;DATE ORDER :<strong>&nbsp;<%=(String)vRetResult.elementAt(4)%></strong></td>
    </tr>
    <tr> 
      <td width="6%" height="25" align="center" class="thinborder"><strong>QTY</strong></td>
      <td colspan="2" align="center" class="thinborder"><strong>DESCRIPTION 
      </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>SHIPPING 
        METHOD</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>INVOICE NO</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>DATE RECEIVED</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>TOTAL COST</strong></td>
    </tr>
    <%for(; i< vRetResult.size() && iCountRows < iNumRows; i+=11,iCountRows++){%>
    <tr> 
      <td height="17" align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td width="34%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%>/<%=(String)vRetResult.elementAt(i+3)%></td>
      <td width="18%" class="thinborderBottom">&nbsp;&nbsp;<%=astrReceiveStat[Integer.parseInt((String)vRetResult.elementAt(i+4))]%> </td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%> </td>
      <td class="thinborder"><%if (((String)vRetResult.elementAt(i+4)).equals("1") || ((String)vRetResult.elementAt(i+4)).equals("2")){%> <%=(String)vRetResult.elementAt(i+6)%> <%}else{%> &nbsp; <%}%> </td><td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+10)%>&nbsp;</td>
    </tr>
    <%}%>
    <%for(;iCountRows < 13;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborderBottom">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
  </table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="40%" height="12" valign="top" class="thinborderLEFT">Received by:</td>
      <td width="30%" rowspan="3" valign="top" class="thinborder">Inspected By: </td>
      <td width="30%" rowspan="3" valign="top" class="tthinborderBOTTOMLEFTRIGHT" >Delivered To : </td>
    </tr>
    <tr> 
      <td height="24" valign="top" class="thinborderLEFT"><div align="center">&nbsp;<strong><%=WI.getStrValue((String)vReqInfo.elementAt(13),"")%></strong></div></td>
    </tr>
    <tr> 
      <td height="15" class="thinborder"><div align="left">Signature over Printed Name</div></td>
    </tr>
  </table>
	<%if (i < vRetResult.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
	}%>
    <%} // if(vReqInfo != null)  	
	}// outermost for loop%>
</body>
</html>
<%
dbOP.cleanUP();
%>
