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
function PageLoad(){
 	document.form_.req_no.focus();
}

function OpenSearchPO(){
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.printPage.value = "1";
	document.form_.submit();
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	
	

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
	
	if(WI.fillTextValue("printPage").length() > 0){%>
		<jsp:forward page="./memo_receipt_print.jsp"></jsp:forward>
<%	return;}
	
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
								"Admin/staff-PURCHASING-DELIVERY","memo_receipt.jsp");
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

Vector vReqItems = null;
Vector vRetResult = null;


int iCount = 1;
String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
String[] astrReqType = {"New","Replacement"};
String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	
if (WI.fillTextValue("proceedClicked").equals("1")){
	vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
	if(vReqInfo == null)
		strErrMsg = DEL.getErrMsg();
	else{
		if(Integer.parseInt(WI.getStrValue((String)vReqInfo.elementAt(3),"0")) != 1){
			strErrMsg = "PO not yet approved";
		}else{
			
			vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0), true);
			if(vRetResult == null)
				strErrMsg = DEL.getErrMsg();
			else
				vReqItems = (Vector)vRetResult.elementAt(1);
		}
	}
}
%>	
<form name="form_" method="post" action="memo_receipt.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
      MEMORANDUM RECEIPT FOR EQUIPMENT PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">PO No. :</td>
      <td width="23%">
			<%if(WI.fillTextValue("req_no").length() > 0){
		  		strTemp = WI.fillTextValue("req_no");
			  }else{
	  			strTemp = "";
      	}%> 
			<input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="61%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
  </table>  
<%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS FOR PURCHASE ORDER NO. : <%=(String)vReqInfo.elementAt(1)%></strong></td>
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
      <td>Office :</td>
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
		<input type="hidden" name="supplier_index" value="<%=(String)vReqInfo.elementAt(14)%>">
  </table>

  <%if(vReqItems != null && vReqItems.size() > 3){%>	
  
  
  <table bgcolor="#FFFFFF" width="100%" border="0">
  	<tr>
			<td height="30" align="right">
			  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
			  <font size="1">click to print</font></td>
		</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM(S) RECEIVED</strong></font></td>
    </tr>
	
	<tr>
		<td width="8%" height="22" align="center" class="thinborder"><strong>QTY</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
		<td width="56%" align="center" class="thinborder"><strong>DESCRIPTION</strong></td>
		<td width="13%" align="center" class="thinborder"><strong>Unit Price</strong></td>
		<td width="13%" align="center" class="thinborder"><strong>TOTAL</strong></td>
	</tr>
	
   
    <%iCount = 1;
	for(int i = 0;i < vReqItems.size();i+=16,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(i+12)%></div></td>
      <td align="center" class="thinborder"><%=(String)vReqItems.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(i+3)%> / <%=(String)vReqItems.elementAt(i+4)%><%=WI.getStrValue((String)vReqItems.elementAt(i+9),"(",")","")%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vReqItems.elementAt(i+14),true)%></td>
      <td class="thinborder" align="right"><%=(String)vReqItems.elementAt(i+15)%></td>     
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></td>
    </tr>
  </table>	
	<%}// end if(vReqItems != null && vReqItems.size() > 3)
}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td width="4%" height="25" colspan="8"></td></tr>
	<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="printPage" value="">
	<input type="hidden" name="search_po" value="1">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>