<%@ page language="java" import="utility.*, health.ClinicVisitLog, health.AUFHealthProgram, java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../common.js"></script>
<script language="javascript">

	function DepSearch() {
		var pgLoc = "./search_dependent.jsp?opner_info=form_.id_number&copy_dep_id=1";
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function ViewDetails(strInfoIndex){
		var pgLoc = "./case_detail.jsp?view_dep=1&info_index="+strInfoIndex+"&visit_index="+strInfoIndex+"&id_number="+document.form_.id_number.value;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function  FocusID() {
		document.form_.id_number.focus();
	}
	
	function PrintPg() {
		
		document.getElementById('myADTable1').deleteRow(0);
		document.getElementById('myADTable1').deleteRow(0);
		document.getElementById('myADTable1').deleteRow(0);
		document.getElementById('myADTable1').deleteRow(0);
		document.getElementById('myADTable1').deleteRow(0);
		
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		
		document.getElementById('myADTable3').deleteRow(0);
	
		alert("Click OK to print this page");
		window.print();//called to remove rows, make bk white and call print.
	}

</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String [] astrYN = {"No", "Yes"};	
	int iSearchResult = 0;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","patient_hist_dependent.jsp");
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
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
															"patient_hist_dependent.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	//end of authenticaion code.
	
	String[] astrGender = {"", "Male", "Female"};
	String[] astrStatus = {"", "Single", "Married", "Widowed/Widower", "Separated"};

	ClinicVisitLog CVLog = new ClinicVisitLog();
	AUFHealthProgram hp = new AUFHealthProgram();
	String strSlash = "";
	Vector vBasicInfo = null;

	if(WI.fillTextValue("id_number").length() > 0) {
		vBasicInfo = hp.getDependentInformation(dbOP, request);
		if(vBasicInfo == null)
			strErrMsg = hp.getErrMsg();
		else{
			vRetResult = CVLog.getDependentPatientHistory(dbOP, request);
			if(vRetResult == null){
				strErrMsg = CVLog.getErrMsg();
				vBasicInfo = null;
			}
			else
				iSearchResult = CVLog.getSearchCount();
		}
	}
%>
<body onLoad="FocusID();">

<form action="patient_hist_dependent.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr> 
			<td height="28" colspan="4" bgcolor="#697A8F" class="footerDynamic">
				<div align="center"><font color="#FFFFFF" ><strong>:::: CLINIC VISIT LOG -DEPENDENT'S LOG PAGE ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="18" colspan="4"><%=WI.getStrValue(strErrMsg)%></td>
		</tr>
		<tr> 
			<td width="3%"  height="28">&nbsp;</td>
			<td width="15%">Enter ID No. :</td>
			<td width="25%">
				<input type="text" name="id_number" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("id_number")%>"></td>
			<td width="57%">
				<a href="javascript:DepSearch();"><img src="../../../images/search.gif" border="0" ></a> 
				<font size="1">Click to search for dependent</font></td>
		</tr>
		<tr> 
			<td height="28" colspan="2">&nbsp;</td>
			<td colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		</tr>
		<tr> 
			<td height="18" colspan="4">&nbsp;</td>
		</tr>
	</table>

<%if(vBasicInfo!=null && vBasicInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="5"><strong>DEPENDENT INFORMATION</strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="15%">Name:</td>
		    <td width="30%"><%=(String)vBasicInfo.elementAt(2)%></td>
		    <td width="15%">Gender:</td>
		    <td width="37%"><%=astrGender[Integer.parseInt((String)vBasicInfo.elementAt(4))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>ID Number: </td>
			<td><%=(String)vBasicInfo.elementAt(1)%></td>
			<td>Civil Status: </td>
			<td><%=astrStatus[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date of Birth: </td>
			<td><%=(String)vBasicInfo.elementAt(3)%></td>
			<td>Membership:</td>
			<td><%=(String)vBasicInfo.elementAt(12)%> - <%=WI.getStrValue((String)vBasicInfo.elementAt(13), "to date")%></td>
		</tr>
	</table>
<%}%>
	
<%if (vRetResult!=null && vRetResult.size()>0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
		<tr> 
			<td height="25" colspan="2" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>Print report</td>
		</tr>
		<tr> 
			<td width="56%" height="25">&nbsp;</td>
			<td width="44%" align="right" style="font-size:9px">Date/time Printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="25" colspan="13" bgcolor="#FFFF9F" class="thinborder"><div align="center"><strong>LIST OF VISITS</strong></div></td>
		</tr>
		<tr>
			<td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Visit Date</strong></font></div></td>
			<td width="12%" class="thinborder"><div align="center"><font size="1"><strong>Case #</strong></font></div></td>
			<td width="13%" class="thinborder"><div align="center"><font size="1"><strong>Doctor/Nurse</strong></font></div></td>
			<td width="20%" class="thinborder"><div align="center"><font size="1"><strong>Purpose of Visit/Complains</strong></font></div></td>
			<td width="20%" class="thinborder"><div align="center"><font size="1"><strong>Diagnosis</strong></font></div></td>
			<td width="20%" class="thinborder"><div align="center"><font size="1"><strong>Treatment Plan</strong></font></div></td>
			<td width="5%" class="thinborder"><div align="center"><font size="1"><strong>Rx Given</strong></font></div></td>
			<td width="14%" class="thinborder"><div align="center"><font size="1"><strong>Referred To </strong></font></div></td>
			<td width="14%" class="thinborder"><div align="center"><font size="1"><strong>Diagnostic</strong></font></div></td>
			<td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Case Status </strong></font></div></td>
		</tr>
	<%for(int i =0; i<vRetResult.size(); i+=30){%>
		<tr>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%><%//=WI.getStrValue((String)vRetResult.elementAt(i+14),"<br>","","")%></td>
			<td class="thinborder"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>)'><%=(String)vRetResult.elementAt(i+2)%></a></td>
				<%
					strTemp = WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),7);
					strTemp2 = WI.formatName((String)vRetResult.elementAt(i+21), (String)vRetResult.elementAt(i+22), (String)vRetResult.elementAt(i+23),7);
					if(strTemp.length() > 0 && strTemp2.length() > 0)
						strSlash = " / ";
				%>
			<td class="thinborder">&nbsp;<%=strTemp%><%=strSlash%><%=strTemp2%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+18))%><br><%=WI.getStrValue(vRetResult.elementAt(i+15),"&nbsp;")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
			<td class="thinborder">&nbsp;<%=astrYN[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+28))%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+29))%></td>
			<td class="thinborder" align="center"><%if(vRetResult.elementAt(i+10).equals("0")){%>Open<%}%>&nbsp;</td>
		</tr>
	<%}%>  
	</table>
<%}//only if vRetResult is not null%>
			
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
		<tr> 
			<td height="10">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="print_page" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>