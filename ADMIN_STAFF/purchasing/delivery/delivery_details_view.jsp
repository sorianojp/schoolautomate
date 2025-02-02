<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}

function UpdateMRNo(){	
		
		var objCOAInput = document.form_.mr_no;
		if(objCOAInput.value.length == 0)
			return;
		
		this.InitXmlHttpObject(objCOAInput, 1);
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=6300&new_value="+escape(objCOAInput.value)+
			"&delivery_index="+document.form_.delivery_index.value;
		this.processRequest(strURL);
	}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,purchasing.Delivery,purchasing.Supplier,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	boolean bolVMA = strSchCode.startsWith("VMA");

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
//add security here.
   if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="delivery_details_print.jsp"/>
	  <%}
		
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","delivery_details_view.jsp");
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

	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	    
	Delivery DEL = new Delivery();	

	Vector vDelInfo = null;
	Vector vRetResult = null;

 	int iCount = 1;
	int iSearchResult = 0;
	int iDefault = 0;

	vRetResult = DEL.getDeliveryInfo(dbOP,request, WI.fillTextValue("delivery_index"),false);
 	if(vRetResult == null)
		strErrMsg = DEL.getErrMsg();
	else{
		iSearchResult = DEL.getSearchCount();
		vDelInfo = (Vector) vRetResult.elementAt(0);
	}

%>	
<form name="form_" method="post" action="./delivery_details_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - VIEW PO RECEIVE STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vDelInfo != null && vDelInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong><font color="#FFFFFF">DELIVERY INFORMATION </font></strong></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>DELIVERY # </td>
      <td><strong><%=(String)vDelInfo.elementAt(1)%></strong></td>
      <td>DELIVERY DATE: </td>
      <td><strong><%=(String)vDelInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="4%">&nbsp;</td>
      <td width="22%">INVOICE # </td>
      <td width="28%"><strong><%=(String)vDelInfo.elementAt(3)%></strong></td>
      <td width="20%">INVOICE DATE : </td>
      <td width="28%"> <strong><%=(String)vDelInfo.elementAt(4)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="2"><div align="center"><strong><font color="#FFFFFF">SUPPLIER  INFORMATION</font></strong></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="21%">Supplier Code : </td>
      <td width="76%"><strong><%=(String)vDelInfo.elementAt(12)%></strong></td>
    </tr>    
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Supplier Name : </td>
      <td><strong><%=(String)vDelInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Address : </td>
      <td><strong><%=(String)vDelInfo.elementAt(7)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Contact Person : </td>
      <td><strong><%=(String)vDelInfo.elementAt(8)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Contact Number : </td>
      <td><strong><%=(String)vDelInfo.elementAt(9)%></strong></td>
    </tr>

  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  		<tr>
			<%
				if(WI.fillTextValue("is_pre_printed").equals("1"))
					strTemp = " checked";
				else
					strTemp = " ";
			%>
			<td width="45%">&nbsp;<input type="checkbox" name="is_pre_printed" value="1" <%=strTemp%>>
			<font size="1">Pre Printed paper</font></td>
		<%if(bolVMA){
			strTemp = "";
			if(WI.fillTextValue("delivery_index").length() > 0){
				strTemp = "select RECEIVING_NO from pur_delivery where is_valid =1 and delivery_index = "+WI.fillTextValue("delivery_index");
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			}
			
		%>
			<td width="28%" align="left">
				MR No 
				<input type="text" name="mr_no" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateMRNo();style.backgroundColor='white'">
			</td>
		<%}%>
		  <td align="right">Items per page</font>
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select><a href="javascript:PrintPage();">
        <img src="../../../images/print.gif" border="0"> </a> <font size="1">click to print</font> </td>
 		  
  		</tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" bgcolor="#B9B292" colspan="6" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
        OF DELIVERED ITEM(S) </strong></font></div></td>
    </tr>
    <tr>
      <td width="11%" height="25" align="center" class="thinborder"><strong>QTY</strong><strong> UNIT</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>CODE</strong></td>
      <td width="46%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
      / DESCRIPTION </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>EXP. DATE </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UP</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
    </tr>
    <%iCount = 1;
	for(int i = 1;i < vRetResult.size();i+=12,++iCount){%>
    <tr>
      <td height="25" align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;<%=(String)vRetResult.elementAt(i+2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> / <%=(String)vRetResult.elementAt(i+4)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","")%></td>
      <td class="thinborder">&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+10);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+11);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
    </tr>
    <%}%>
  </table>
  <%}}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
	<input type="hidden" name="delivery_index" value="<%=WI.fillTextValue("delivery_index")%>">	
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>