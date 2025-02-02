<%@ page language="java" import="utility.*, docTracking.deped.DocReceiveRelease, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolFromPending = false;//WI.fillTextValue("is_forwarded").equals("1");
	boolean bolFromSearch = false;//WI.fillTextValue("is_forwarded").equals("2");
	boolean bolForwarded = false;//bolFromPending || bolFromSearch;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Document Tracking</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	function FocusField(){
		document.form_.barcode_id.focus();
	}
	
	function SearchBarcode(strKeyCode){
		document.form_.submit();	
	}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation();
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	Vector vInfo = null;
	Vector vRetResult = null;
	DocReceiveRelease drr = new DocReceiveRelease();
	DocumentTracking dt = new DocumentTracking();
	if(WI.fillTextValue("barcode_id").length() > 0 || WI.fillTextValue("doc_name").length() > 0 || WI.fillTextValue("doc_owner").length() > 0){
		vInfo = drr.getTransactionInformation(dbOP, request);
		if(vInfo == null)
			strErrMsg = drr.getErrMsg();
		else{
			vRetResult = dt.trackDocument(dbOP, request, (String)vInfo.elementAt(0), null);
			if(vRetResult == null)
				strErrMsg = dt.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="online_doc_tracking.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="20" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  ONLINE DOCUMENT TRACKING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="17%">Barcode ID: </td>
			<td width="80%">
				<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("barcode_id")%>"/>			</td>
		</tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td>Document Name </td>
		  <td>
				<input type="text" name="doc_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("doc_name")%>"/>		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td>Document Owner </td>
		  <td>
				<input type="text" name="doc_owner" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("doc_owner")%>"/>		  </td>
	  </tr>
		
	<%if(!bolForwarded){%>
		<tr>
			<td height="20" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:SearchBarcode('13');"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click here to search barcode.</font></td>
		</tr>
	<%}%>
	</table>

<%if(vInfo != null && vInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr> 
		<tr>
			<td height="20" colspan="3"><strong><u>TRANSACTION INFORMATION</u></strong></td>
	    </tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="17%">Origin/Owner:</td>
			<td width="80%"><%=(String)vInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Transaction Date: </td>
			<td><%=(String)vInfo.elementAt(17)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Category: </td>
			<td><%=(String)vInfo.elementAt(2)%></td>
		</tr>
		<%
			strTemp = (String)vInfo.elementAt(14);
			if(strTemp.equals("1")){
				strErrMsg = "Complete/";
				
				if(((String)vInfo.elementAt(15)).equals("1"))
					strErrMsg += "Released";
				else
					strErrMsg += "Unreleased";
			}
			else
				strErrMsg = "In Process";
		%>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Status: </td>
			<td><%=strErrMsg%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Document Name: </td>
			<td rowspan="2" valign="top"><%=(String)vInfo.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
<!--
		<tr>
			<td height="20">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td><a href="javascript:ViewTransactionDetails('<%=(String)vInfo.elementAt(5)%>');"><img src="../../images/view.gif" border="0" /></a>
				<font size="1">Click to view transaction details</font></td>
		</tr>
		<tr>
		  	<td height="15" colspan="3">&nbsp;</td>
	  	</tr>
-->
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: DOCUMENT STATUS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="20" width="11%" align="center" class="thinborder"><strong>Office/Dept</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Received by</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Date/Time</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Remarks</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Release by</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Date/Time</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Remarks</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Action</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Duration</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 18){%>
		<tr>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+1));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+2));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
			%>
			<td height="20" class="thinborder">&nbsp;<!--
			<a href="javascript:ShowDetails('<%=(String)vRetResult.elementAt(i+16)%>', '<%=(String)vInfo.elementAt(0)%>')"
					style="text-decoration:none">--><%=strTemp%><!--</a>--></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp == null)
					strTemp = "-In Process-";
				else if(strTemp.equals("1")){//forwarded
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14));
					strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+15));
					
					if(strTemp.length() > 0 && strErrMsg.length() > 0)
						strTemp += "/ ";
					strTemp += strErrMsg;
					strTemp = "FWD to "+strTemp;
				}
				else if(strTemp.equals("2"))//closed
					strTemp = "Completed";
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+17)%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>