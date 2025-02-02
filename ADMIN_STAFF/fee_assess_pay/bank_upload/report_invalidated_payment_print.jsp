<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) {%>
		<p style="font-size:15px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
			You are already logged out. Please login again.
		</p>
	<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Non-Posting Payments Mgmt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">	

	
	function SearchTemp(){
		document.form_.search_temp.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.search_temp.value = "";
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
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
	
	Vector vRetResult = null;
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	BankPosting bp = new BankPosting();	
	Vector vBankList = new Vector();
	
		vRetResult = bp.getBankPostListing(dbOP, request);
		if(vRetResult == null)
			strErrMsg = bp.getErrMsg();
		else
			vBankList = (Vector)vRetResult.remove(0);
		
	

%>
<body>
<%if(vRetResult != null && vRetResult.size() > 0){


boolean bolIsPageBreak = false;
int iResultSize = 15;
int iLineCount = 0;
int iMaxLineCount = 40;	
int iCount = 0;	
int i = 0;
while(iResultSize <= vRetResult.size()){
	iLineCount = 0;
%>	
	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
		<tr><td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div><br></td></tr>
		<tr>
		<tr>
		  <td align="center" height="20">LIST OF BANK COLLECTION </td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" align="center" class="thinborder" width="13%"><strong>ID Number </strong></td>
		    <td align="center" class="thinborder" width="22%"><strong>Name</strong></td>
		    <td align="center" class="thinborder" width="15%"><strong>SY/Term</strong></td>
		    <td align="center" class="thinborder" width="12%"><strong>Date Paid</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>OR Number</strong> </td>
		    <td align="center" class="thinborder" width="13%"><strong>Amount</strong></td>
			<td align="center" class="thinborder" width="10%"><strong>Bank</strong></td>
			<td align="center" class="thinborder" width="10%"><font size="1"><strong>Created By</strong></font></td>
		</tr>
		<%			
		for(;i<vRetResult.size();){
		
		iCount++;
		iLineCount++;		
		iResultSize += 15;	
		
		%>
		<tr>
			<td height="20" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%>-<%=((String)vRetResult.elementAt(i+7)).substring(2)%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+11)%></td>
		    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+14))%></td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
		</tr>
		<%
		i+=15;
		if(iLineCount > iMaxLineCount){
			bolIsPageBreak = true;
			break;		
		}else
			bolIsPageBreak = false;	
		%>
	<%}%>
	</table>	
	
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
	
<%}if(iResultSize > vRetResult.size()){%>		
	<%if(vBankList != null && vBankList.size() > 0 && WI.fillTextValue("show_bank").equals("1")){%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr><td>&nbsp;</td></tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder"	>		
		<tr>
			<td class="thinborder" height="20"><strong>Bank Code</strong></td>
			<td class="thinborder" height="20"><strong>Amount</strong></td>
		</tr>
		
		<%for(i = 0; i < vBankList.size(); i+=4){
			strTemp = (String)vBankList.elementAt(i+2);
			if(strTemp == null)
				strTemp = "Manual Posted";
		%>
		<tr>
			<td class="thinborder" height="20"><%=strTemp%></td>
			<td class="thinborder" height="20"><%=(String)vBankList.elementAt(i+3)%></td>
		</tr>
		<%}%>
	</table>
	<%}
	}%>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>