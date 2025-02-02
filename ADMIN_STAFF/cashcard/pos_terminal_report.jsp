<%@ page language="java" import="utility.*,cashcard.Pos,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>POS Terminal Report</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">
function PrintPg(strInfoIndex,strDate,strDate2)
{
	var loadPg = "./pos_print.jsp?info_index="+strInfoIndex+"&TRANSACTION_DATE="+strDate+"&TRANSACTION_DATE2="+strDate2; 
	var win=window.open(loadPg,"myfile",'dependent=no,width=350,height=350,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPTR(strInfoIndex,strDate,strDate2)
{
	var loadPg = "./PTR_print.jsp?jumpto="+strInfoIndex+"&info_index=null&TRANSACTION_DATE="+strDate+"&TRANSACTION_DATE2="+strDate2;	
	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=500,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this entry?'))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {	
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.submit();
}
function SearchCollection() {
		document.form_.searchCollection.value = "1";
		document.form_.submit();
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String mName = null;

	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-POS TERMINAL REPORT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-POS TERMINAL REPORT","pos_terminal_report.jsp");					
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
	//authenticate this user.
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vTransResult = null;
	Vector vIPResult = null;
	Vector vStudInfo  = null; 
	int i = 0;
	int iSearchResult = 0;
	boolean bolIsBasic = false;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertSem     = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	
	Pos cardTrans = new Pos();
	enrollment.FAPaymentUtil pmtUtil = new enrollment.FAPaymentUtil();
	
	vIPResult = cardTrans.operateOnIPFilter(dbOP, request);
	if (vIPResult == null) {%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=cardTrans.getErrMsg()%></p>
	<%
		dbOP.cleanUP();
		return;	
	}	
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(cardTrans.operateOnTransaction(dbOP, request, Integer.parseInt(strTemp), null) == null)
			strErrMsg = cardTrans.getErrMsg();
	else {
		if(strTemp.compareTo("0") == 0)
			strErrMsg = "Transaction successfully removed.";
		else if(strTemp.compareTo("1") == 0)
			strErrMsg = "Transaction successfully added.";
		else if(strTemp.compareTo("2") == 0)
			strErrMsg = "Transaction successfully edited.";
	
		strPrepareToEdit = "0";
	}
	}
	if(WI.fillTextValue("searchCollection").equals("1")){
		vTransResult = cardTrans.operateOnTransaction(dbOP, request, 4,"0");
		if(vTransResult == null && strErrMsg == null)
			strErrMsg = cardTrans.getErrMsg();
		else	
			iSearchResult = cardTrans.getSearchCount();
	}
%>		
<body bgcolor="#D2AE72">
<form action="pos_terminal_report.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center"><font color="#FFFFFF"><strong>::::
        <%=(String)vIPResult.elementAt(3)%> - POS TRANSACTION REPORTS ::::</strong></font></td>
    </tr>
	<tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
	<tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" >
	  Transaction Date: &nbsp;&nbsp;&nbsp;<sup>From:</sup></font>
	  <%
	  	strTemp = WI.fillTextValue("TRANSACTION_DATE");
	  %>
	  <input type="text" name="TRANSACTION_DATE" size="16" maxlenght="64" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">
	  <a href="javascript:show_calendar('form_.TRANSACTION_DATE');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  &nbsp;&nbsp;&nbsp; - &nbsp;&nbsp;&nbsp;<sup>To:</sup></font>
	  	  <%
	  	strTemp = WI.fillTextValue("TRANSACTION_DATE2");
	  %>
	  <input type="text" name="TRANSACTION_DATE2" size="16" maxlenght="64" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">
	  <a href="javascript:show_calendar('form_.TRANSACTION_DATE2');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  <input type="submit" name="" value="List Transaction" onclick="SearchCollection();" />
	  <input type="hidden" name="list_order" value="asc" />
	</td>
    </tr>
	<tr>
		<td colspan="2" height="25"></td>
	</tr>
</table>
<%if(vTransResult != null) {%>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
<tr bgcolor="#DDDDEE"> 
  <td height="25" colspan="6" class="thinborder" align="center">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
     <td width="85%" align="center"><font color="#FF0000"><strong>LIST OF TRANSACTIONS </strong></font></td>
     <td width="15%" align="right">
	 <font size="2" color="#FF0000">Total:<strong><%=(String)vTransResult.remove(0)%></strong></font>
    </td>
  </tr>
  </table>
  </td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#FFFFFF"> 
  <td width="72%" class="thinborderLEFT"><strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=cardTrans.getDisplayRange()%></strong>)</strong></td>
  <td width="28%" class="thinborderRIGHT" height="25">&nbsp;
  <%
	int iPageCount = 1;
	iPageCount = iSearchResult/cardTrans.defSearchSize;		
	if(iSearchResult % cardTrans.defSearchSize > 0) 
		++iPageCount;
	strTemp = " - Showing("+cardTrans.getDisplayRange()+")";
	if(iPageCount > 1){%> 
		<div align="right">Jump To page: 
		<select name="jumpto" onChange="SearchCollection();">
		<%
		  strTemp = WI.fillTextValue("jumpto");
		  if(strTemp == null || strTemp.trim().length() ==0)
		  	strTemp = "0";
		  i = Integer.parseInt(strTemp);
		  if(i > iPageCount)
			strTemp = Integer.toString(--i);
		  for(i =1; i<= iPageCount; ++i ){
			if(i == Integer.parseInt(strTemp) ){%>
				<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
			<%}else{%>
				<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
			<%}
		  }
		%>
		</select>
		</div>
	<%}%>
  </td>
</tr>
</table>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
<tr style="font-weight:bold" align="center">
  <td class="thinborder" style="font-size:9px;" width="7%" height="25">Operation</td>
  <td class="thinborder" style="font-size:9px;" width="7%">Student ID</td> 
  <td class="thinborder" style="font-size:9px;" width="20%">Name</td> 
  <td class="thinborder" style="font-size:9px;" width="9%">Reference</td> 
  <td class="thinborder" style="font-size:9px;" width="23%">Transaction Note</td> 
  <td class="thinborder" style="font-size:9px;" width="9%">Posted By </td> 
  <td class="thinborder" style="font-size:9px;" width="16%">Transaction Date</td>  
  <td class="thinborder" style="font-size:9px;" width="7%">Amount</td>
  </tr>
<%
for(i = 0; i < vTransResult.size(); i += 13){
%>	
<tr> 
  <td height="25" class="thinborder" align="center">&nbsp;
  <a href="javascript:PrintPg(<%=(String)vTransResult.elementAt(i)%>,'<%=WI.fillTextValue("TRANSACTION_DATE")%>','<%=WI.fillTextValue("TRANSACTION_DATE2")%>');"><img src="../../images/print.gif" border="0" /></a></td>	
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 9)%></td>
  <td class="thinborder">&nbsp;
  <%=(String)vTransResult.elementAt(i + 12)%>, 
  <%=(String)vTransResult.elementAt(i + 10)%> 
  <%
  	mName = (String)vTransResult.elementAt(i + 11);
	mName = mName.substring(0,1);
  %>
  <%=mName%>.</td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 3)%></td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 4)%></td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 6)%></td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 2)%></td>
  <td class="thinborder" align="right">&nbsp;
  <%=CommonUtil.formatFloat((String)vTransResult.elementAt(i + 5), true)%></td>
  </tr>
<%}//End of vTransResut%>	
<tr>
  <td colspan="8" align="right"><a href="javascript:PrintPTR(<%=WI.fillTextValue("searchCollection")%>,'<%=WI.fillTextValue("TRANSACTION_DATE")%>','<%=WI.fillTextValue("TRANSACTION_DATE2")%>');"><img src="../../images/print.gif" border="0" /></a></td>
</tr>
</table>
<%}//End of vTransResult if not null%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <tr bgcolor="#A49A6A"> 
    <td width="50%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="terminal_ip_index" value="<%=(String)vIPResult.elementAt(0)%>" />
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>