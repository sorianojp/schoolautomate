<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script src="../../jscript/common.js"></script>
<script language="javascript">
function OpenSearch() {
	var pgLoc = "../search/search_simple.jsp?opner_info=form_.accession_no&opner_info2=form_.reload_main&opner_info2_val=1";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateSupplier() {
	var pgLoc = "./supplier.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

	try {
		dbOP = new DBOperation();
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

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
boolean bolIsFinal = false;

LmsAcquision lmsAcq = new LmsAcquision();
Vector vRetResult   = null; Vector vAcqMainInfo = null; Vector vSelList = null; // this is the list of book not yet selected for acquisition.. 
Vector vEditInfo    = null;

String strAcqRef = WI.fillTextValue("acq_index");
if(strAcqRef.length() == 0) 
	strErrMsg = "Acquisition main reference index is missing. Please close this window and try again.";
else {
	vAcqMainInfo = lmsAcq.operateOnAcquisitionDtls(dbOP, request, 5);
	if(vAcqMainInfo == null)
		strErrMsg = lmsAcq.getErrMsg();
	strTemp = (String)vAcqMainInfo.elementAt(8);
	
	strTemp = ConversionTable.replaceString(strTemp,",","");
	
	//try{			
		if(Double.parseDouble(strTemp) > 0d)				
			bolIsFinal = true;				
	//}catch(NumberFormatException nfe) {
    //    bolIsFinal = true;	       
    //}
	

}

if(vAcqMainInfo != null) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(lmsAcq.operateOnAcquisitionDtls(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = lmsAcq.getErrMsg();
		else {
			strErrMsg = "Request processed successfully.";
			strPreparedToEdit = "0";
		}
	}
	vRetResult = lmsAcq.operateOnAcquisitionDtls(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = lmsAcq.getErrMsg();
	
	if(strPreparedToEdit.equals("1")) {
		vEditInfo = lmsAcq.operateOnAcquisitionDtls(dbOP, request, 3);
		if(vEditInfo == null) {
			strErrMsg = lmsAcq.getErrMsg();
			strPreparedToEdit = "0";
		}
	}
}
%>
<body bgcolor="#FAD3E0">
<form action="./acquisition_dtls.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: ACQUISITION - BOOK SELECTION  PAGE ::::</strong></font></div></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr>
		<td colspan="3" style="font-size:13px; font-weight:bold; color:#FF0000"> &nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
	  </tr>
<%if(vAcqMainInfo == null){
	dbOP.cleanUP();
	return;
}
strTemp = (String)vAcqMainInfo.elementAt(3);%>
	  <tr>
		<td width="10%" height="24">School Year : </td>
		<td width="10%"><b><%=strTemp%> - <%=Integer.parseInt(strTemp) + 1%></b></td>
		<td width="80%">Reference Number : <b><%=vAcqMainInfo.elementAt(1)%></b></td>
	  </tr>
	  <tr>
		<td height="24">Course</td>
		<td colspan="2"><b><%=vAcqMainInfo.elementAt(6)%></b></td>
	  </tr>
	  <tr>
		<td height="24">Remarks</td>
		<td colspan="2"><b><%=WI.getStrValue(vAcqMainInfo.elementAt(0))%></b> &nbsp;</td>
	  </tr>
	  <tr>
	    <td height="24">Balance</td>
	    <td colspan="2">&nbsp;</td>
      </tr>
	</table>
    
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="12"><hr size="1"></td>
      </tr>
<%
vSelList = lmsAcq.getBookSelForAcquisition(dbOP, (String)vAcqMainInfo.elementAt(3), (String)vAcqMainInfo.elementAt(7));
if(vSelList == null) {%>
      <tr>
        <td height="12">&nbsp;&nbsp;&nbsp; <%=lmsAcq.getErrMsg()%></td>
      </tr>
<%}else{%>
      <tr>
        <td>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#CCCCCC">
				  <tr bgcolor="#9DB6F4">
					<td height="25" colspan="9" align="center" class="thinborder"><font color="#FFFFFF" ><strong>:::: LIST OF BOOKS TO SELECT FOR ACQUISITION ::::</strong></font></td>
				  </tr>
				  <tr bgcolor="#C6D3F4" align="center" style="font-weight:bold">
					<td width="5%" class="thinborder">Count</td>
					<td width="15%" height="25" class="thinborder">Author</td>
					<td width="20%" class="thinborder">Title</td>
					<td width="8%" class="thinborder">Edition</td>
					<td width="20%" class="thinborder">Supplier</td>
					<td width="8%" class="thinborder">Unit Price</td>
					<td width="7%" class="thinborder">Qty</td>
					<td width="12%" class="thinborder">Discount per book </td>
					<td width="5%" class="thinborder">Select</td>
				  </tr>
				<%
				int j = 0;
				for(int i = 0; i < vSelList.size(); i += 11,++j){
				if(vSelList.elementAt(i + 10) != null) {%>
				  <tr bgcolor="#FFFFDD">
					<td height="20" colspan="9" class="thinborder"><strong>Selection Reference Number : <%=vSelList.elementAt(i + 10)%></strong></td>
				  </tr>
				<%}%>
				  <tr>
					<td class="thinborder"><%=i/11 + 1%>.</td>
					<td height="20" class="thinborder"><%=vSelList.elementAt(i + 1)%></td>
					<td class="thinborder"><%=vSelList.elementAt(i + 4)%></td>
					<%strTemp = (String)vSelList.elementAt(i + 2);
						if(strTemp != null)
							strTemp = (String)vSelList.elementAt(i + 2);
						else
							strTemp = "";
					%>
					<td class="thinborder">&nbsp;<%=strTemp%></td>
					<td class="thinborder"><%=vSelList.elementAt(i + 8)%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat((String)vSelList.elementAt(i + 9), true)%></td>
					<td class="thinborder" align="right"><%=vSelList.elementAt(i + 7)%> &nbsp;</td>
					<td class="thinborder" align="center"><select name="disc_unit_<%=j%>" style="font-size:10px;">
						<option value="0">Amt</option>
						<%
						strTemp = WI.fillTextValue("disc_unit_"+j);
						if(strTemp.equals("1"))
							strTemp = " selected";
						else
							strTemp = "";
						%><option value="1"<%=strTemp%>>%ge</option>
					</select>
					  <input name="discount_<%=j%>" type="text" size="6" maxlength="6" value="<%=WI.fillTextValue("discount_"+j)%>" 
					  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyIntegerExtn('form_','discount_<%=j%>','.');style.backgroundColor='white'" style="font-size:11px;"
						 onKeyUp="AllowOnlyIntegerExtn('form_','discount_<%=j%>','.');">
					</td>
					<td class="thinborder" align="center">
						<input type="checkbox" name="disp_<%=j%>" value="<%=vSelList.elementAt(i)%>">					</td>
				  </tr>
				<%}%>
				<input type="hidden" name="max_disp" value="<%=j%>">
				  <tr>
						<td height="20" colspan="9" align="center" class="thinborder"><input type="submit" name="_1" value="Save for Acquisition" onClick="document.form_.page_action.value='1';"></td>
				  </tr>
				</table>		
		</td>
      </tr>
<%}//show only if vSelList is not null.. %>

    </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
String strTotalBooks = (String)vRetResult.remove(0);
String strTotalAmt   = (String)vRetResult.remove(0);
%><br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#9DB6F4">
    <td height="25" colspan="10" align="center" class="thinborder"><font color="#FFFFFF" ><strong>:::: LIST OF BOOKS TO SELECT FOR ACQUISITION ::::</strong></font></td>
  </tr>
  <tr bgcolor="#C6D3F4" align="center" style="font-weight:bold">
    <td width="5%" class="thinborder">Count</td>
    <td width="15%" height="25" class="thinborder">Author</td>
    <td width="20%" class="thinborder">Title</td>
    <td width="8%" class="thinborder">Edition</td>
    <td width="20%" class="thinborder">Supplier</td>
    <td width="8%" class="thinborder">Unit Price</td>
    <td width="7%" class="thinborder">Qty</td>
    <td width="6%" class="thinborder">Discount</td>
    <td width="6%" class="thinborder">Total Cost </td>
    <td width="5%" class="thinborder">Delete</td>
  </tr>
  <%
				String[] astrConvertDiscUnit = {"Amt","%ge"};
				for(int i = 0; i < vRetResult.size(); i += 16){
				%>
				  <tr>
					<td class="thinborder"><%=i/16 + 1%>.</td>
					<td height="20" class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
					<td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
					<%strTemp = (String)vRetResult.elementAt(i + 4);
						if(strTemp != null)
							strTemp = (String)vRetResult.elementAt(i + 4);
						else
							strTemp = "";
					%>
					<td class="thinborder">&nbsp;<%=strTemp%></td>
					<td class="thinborder"><%=vRetResult.elementAt(i + 13)%></td>
					<td class="thinborder"><%=vRetResult.elementAt(i + 11)%></td>
					<td class="thinborder"><%=vRetResult.elementAt(i + 9)%> &nbsp;</td>
					<td class="thinborder"><%=vRetResult.elementAt(i + 2)%> <%=astrConvertDiscUnit[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></td>
					<td class="thinborder" align="right"><%=vRetResult.elementAt(i + 15)%> &nbsp;</td>
					<td class="thinborder" align="center"><%if(bolIsFinal){%>N/A<%}else{%><input name="submit22" type="submit" style="font-size:11px; height:18px;border: 1px solid #FF0000;" value="Delete" onClick="document.form_.page_action.value='0'; document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'"><%}%></td>
				  </tr>
				<%}%>
  <tr>
    <td height="20" colspan="10" align="left" class="thinborder">&nbsp;&nbsp;&nbsp; 
		Total Books Selected : <%=strTotalBooks%> &nbsp;&nbsp;&nbsp;&nbsp; 
		Total Amount of Acquisition : <%=strTotalAmt%>	</td>
  </tr>
</table>
<%}//only if vRetResult is not null %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="49%" valign="middle">&nbsp;</td>
    <td width="50%" valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#0D3371">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="acq_index" value="<%=WI.fillTextValue("acq_index")%>">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>