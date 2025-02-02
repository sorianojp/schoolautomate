 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,purchasing.Endorsement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="endorsement_dtls_view_print.jsp"/>
	<%}
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-ENDORSEMENT"),"0"));
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
								"Admin/staff-PURCHASING-ENDORSEMENT-Endorsement details","endorsement_dtls_view.jsp");
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
	
	Endorsement EN = new Endorsement();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItemsPO = null;
	Vector vReqItemsEn = null;	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	int iLoop = 0;
	int iCount = 0;
		
	vReqInfo = EN.operateOnReqInfoEn(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = EN.getErrMsg();
	else{
		if(WI.fillTextValue("pageAction").length() > 0){
			vRetResult = EN.operateOnLogEndorsement(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")),(String)vReqInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = EN.getErrMsg();
		}
		vRetResult = EN.operateOnLogEndorsement(dbOP,request,4,(String)vReqInfo.elementAt(0));
		if(vRetResult == null)
			strErrMsg = EN.getErrMsg();
		else{
			vReqItemsPO = (Vector)vRetResult.elementAt(0);
			vReqItemsEn = (Vector)vRetResult.elementAt(1);				
		}			
	}
%>
<form name="form_" method="post" action="endorsement_dtls_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENDORSEMENT - VIEW ENDORSEMENT DETAILS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR PURCHASE ORDER NO. : <%=(String)vReqInfo.elementAt(1)%></strong></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO Status:</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
      <td>PO Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(10)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>College/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"><div align="center"></div></td>
    </tr>
  </table>
  <%if(vReqItemsPO != null && vReqItemsPO.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td  height="25" colspan="6" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
          OF PO ITEM(S)</strong></font></td>
    </tr>
    <tr> 
      <td width="8%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="43%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION </strong></td>
      <td width="15%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>TOTAL PRICE</strong></td>
    </tr>
    <%for(iLoop = 1,iCount = 1;iLoop < vReqItemsPO.size();iLoop+=12,++iCount){%>
    <tr> 
      <td height="26" align="center" class="thinborder"><%=iCount%></td>
      <td align="center" class="thinborder"><%=vReqItemsPO.elementAt(iLoop+10)%></td>
      <td class="thinborder"><%=vReqItemsPO.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=vReqItemsPO.elementAt(iLoop+3)%> / <%=vReqItemsPO.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItemsPO.elementAt(iLoop+8),"(",")","")%>        </td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsPO.elementAt(iLoop+6),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsPO.elementAt(iLoop+7),"&nbsp;")%>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount-1%>
        <input type="hidden" name="numOfItems" value="<%=iCount-1%>">
      </strong></td>
      <td height="25" align="right" class="thinborder"><strong>TOTAL 
          AMOUNT : </strong></td>
      <td align="right" class="thinborder"><strong><%=WI.getStrValue(vReqItemsPO.elementAt(0),"&nbsp;")%>&nbsp;</strong></td>
    </tr>
  </table>
  <%}if(vReqItemsEn != null && vReqItemsEn.size() > 3){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
          OF PO ITEM(S) ENDORSED</strong></font></td>
    </tr>
    <tr> 
      <td width="9%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="43%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION </strong></td>
      <td width="15%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>TOTAL PRICE</strong></td>
    </tr>
    <%
		for(iLoop = 1,iCount = 1;iLoop < vReqItemsEn.size();iLoop+=12,++iCount){%>
    <tr> 
      <td height="26" align="center" class="thinborder"><%=iCount%></td>
      <td align="center" class="thinborder"><%=vReqItemsEn.elementAt(iLoop+10)%></td>
      <td class="thinborder"><%=vReqItemsEn.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=vReqItemsEn.elementAt(iLoop+3)%> / <%=vReqItemsEn.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItemsEn.elementAt(iLoop+8),"(",")","")%>        </td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsEn.elementAt(iLoop+6),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsEn.elementAt(iLoop+7),"&nbsp;")%>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></td>
      <td height="25" align="right" class="thinborder"><strong>TOTAL 
          AMOUNT : </strong></td>
      <td align="right" class="thinborder"><strong><%=WI.getStrValue(vReqItemsEn.elementAt(0),"&nbsp;")%>&nbsp;</strong></td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="8"><div align="center">
	  <a href="javascript:PrintPage();">
	  <img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to PRINT this endorsment record</font></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <%}%>  
  <!-- all hidden fields go here -->
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="req_no" value="<%=WI.fillTextValue("req_no")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
