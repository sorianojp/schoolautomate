<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderRIGHTDOTTED {
    border-right: dotted 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderBOTTOMRIGHTDOTTED {
    border-bottom: solid 1px #000000;
    border-right: dotted 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

</style>
</head>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
}
function OpenSearch() {
	var strPatIndex = "";
	var vObj;
	var totCount    = document.form_.pat_type_count.value;
	for(i = 0 ; i < eval(totCount); ++i) {
		eval('vObj = document.form_.patront_i'+i);
		if(!vObj.checked)
			continue;
			
		if(strPatIndex.length == 0)
			strPatIndex = vObj.value;
		else	
			strPatIndex = strPatIndex + ","+vObj.value; 
	}
	var pgLoc = "./search_patron.jsp?frm_accountability=1&pat_index="+strPatIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SearchPage() {
	var strPatIndex = "";
	var vObj;
	var totCount    = document.form_.pat_type_count.value;
	for(i = 0 ; i < eval(totCount); ++i) {
		eval('vObj = document.form_.patront_i'+i);
		if(!vObj.checked)
			continue;
			
		if(strPatIndex.length == 0)
			strPatIndex = vObj.value;
		else	
			strPatIndex = strPatIndex + ","+vObj.value; 
	}
	document.form_.pat_type_index.value = strPatIndex;
	document.form_.search_.value = "1";
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<%@ page language="java" import="utility.*,lms.CirculationReport,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation","accountability_summary.jsp");
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


//end of authenticaion code.
CirculationReport cReport = new CirculationReport();
Vector vRetResult = null;
if(WI.fillTextValue("search_").length() > 0) {
	//search here. 
	vRetResult = cReport.accountabilitySummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = cReport.getErrMsg();
}

java.sql.ResultSet rs = null;
%>
<body bgcolor="#D0E19D" topmargin="0" bottommargin="0">
<form action="./accountability_summary.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          OVERDUE SUMMARY REPORT ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;<a href="reports_main.jsp"><img src="../../images/goback_circulation.gif" width="54" height="29" border="0"></a>&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr>
      <td height="23" colspan="2">
<%
strTemp = WI.fillTextValue("inc_od_fine");
if(strTemp.length() > 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>&nbsp;&nbsp;
<%if(false){%><input type="checkbox" name="inc_od_fine" value="1"<%=strErrMsg%>> Include running fine (Overdue)
<%}%>
</td>
    </tr>
    <tr>
      <td height="23">&nbsp;Overdue Date </td>
      <td><input name="od_fr" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("od_fr")%>">
        <a href="javascript:show_calendar('form_.od_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font> to 
        <input name="od_to" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("od_to")%>">
      <a href="javascript:show_calendar('form_.od_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font>(optional) </td>
    </tr>
    <tr>
      <td height="23" width="16%">&nbsp;<strong>More Filters : - </strong></td>
      <td width="84%">&nbsp;</td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>
	  	<table width="95%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
			<tr>
				<td class="thinborderNONE" width="50%">Starting from ID: 
					<input type="text" name="id_fr" value="<%=WI.fillTextValue("id_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="24" maxlength="32" style="height:18; font-size:10px;">				</td>
			  <td class="thinborderNONE" width="50%">Ending At ID: 
			  	<input type="text" name="id_to" value="<%=WI.fillTextValue("id_to")%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="24" maxlength="32" style="height:18; font-size:10px;">
			  	&nbsp;&nbsp;<a href="javascript:OpenSearch();">Search</a></td>
			</tr>
			<tr>
				<td class="thinborderNONE" width="50%"><u>Patron Type :</u></td>
			  <td class="thinborderNONE" width="50%">&nbsp;</td>
			</tr>
			<tr>
			  <td class="thinborderNONE" colspan="2">
			  		<table border="0" cellpadding="0" cellspacing="0">
					<%int iTotCount = 0; 
					rs = dbOP.executeQuery("select PATRON_TYPE_INDEX, PATRON_TYPE from LMS_PATRON_TYPE order by PATRON_TYPE");
					while(rs.next()) {
						strTemp = WI.fillTextValue("patront_i"+iTotCount);
						if(strTemp.length() > 0 || request.getParameter("show_con") == null) 
							strTemp = " checked";
						else	
							strTemp = "";
						%>
						<tr>
							<td class="thinborderNONE"><input type="checkbox" name="patront_i<%=iTotCount++%>" value="<%=rs.getString(1)%>"<%=strTemp%>><%=rs.getString(2)%></td>
							<td class="thinborderNONE"><%if(rs.next()){
							strTemp = WI.fillTextValue("patront_i"+iTotCount);
							if(strTemp.length() > 0 || request.getParameter("show_con") == null) 
								strTemp = " checked";
							else	
								strTemp = "";%>
								<input type="checkbox" name="patront_i<%=iTotCount++%>" value="<%=rs.getString(1)%>"<%=strTemp%>><%=rs.getString(2)%>
							<%}else{%>&nbsp;<%}%></td>
							<td class="thinborderNONE"><%if(rs.next()){
							strTemp = WI.fillTextValue("patront_i"+iTotCount);
							if(strTemp.length() > 0 || request.getParameter("show_con") == null) 
								strTemp = " checked";
							else	
								strTemp = "";%>
								<input type="checkbox" name="patront_i<%=iTotCount++%>" value="<%=rs.getString(1)%>"<%=strTemp%>><%=rs.getString(2)%>
							<%}else{%>&nbsp;<%}%></td>
							<td class="thinborderNONE"><%if(rs.next()){
							strTemp = WI.fillTextValue("patront_i"+iTotCount);
							if(strTemp.length() > 0 || request.getParameter("show_con") == null) 
								strTemp = " checked";
							else	
								strTemp = "";%>
								<input type="checkbox" name="patront_i<%=iTotCount++%>" value="<%=rs.getString(1)%>"<%=strTemp%>><%=rs.getString(2)%>
							<%}else{%>&nbsp;<%}%></td>
						</tr>
					<%}rs.close();%><input type="hidden" name="pat_type_count" value="<%=iTotCount%>">
					</table>			  </td>
		  </tr>
  	  </table>	  </td>
    </tr>
    <tr>
      <td height="23">Report Title </td>
      <td><span class="thinborderNONE">
        <input type="text" name="report_name" value="<%=WI.fillTextValue("report_name")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="75" maxlength="100" style="height:20; font-size:11px;">
      </span></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>
	  <input type="submit" name="1" value="&nbsp; Search &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  	onClick="SearchPage();"></td>
    </tr>
    <tr> 
      <td height="19" colspan="2"><div align="right">  
          <hr size="1">
        </div></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr> 
      <td height="42">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print_circulation.gif" border="0"></a>
	  	<font size="1">click to print report</font></div></td>
    </tr>
    <tr> 
      <td height="42" colspan="3" align="center">
          <font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></td>
    </tr>
    <tr>
      <td height="10" colspan="3" align="right">
	  <font size="1">Date and time printed : <%=WI.getTodaysDateTime()%></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
<%if(WI.fillTextValue("report_name").length() > 0) {%>
    <tr>
      <td height="10" colspan="3" align="center" style="font-size:12px;font-weight:bold;"><u><%=WI.fillTextValue("report_name")%></u></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="15%" height="25"><div align="center"><strong><font size="1">ACCESSION # </font></strong></div></td>
      <td width="40%" align="center"><strong><font size="1">BOOK TITLE </font></strong></td>
      <td width="20%" align="center"><strong><font size="1">DUE DATE</font></strong></td>
      <td width="10%"><div align="center"><strong><font size="1">FINE</font></strong></div></td>
      <td width="15%" align="center"><strong><font size="1">FINE TYPE</font></strong></td>
    </tr>
<%
//[0] id number, [1] name, [2] accession_#, [3] book_title, [4] to_return_date, 
//[5] to_return_time, [6] tot fine, [7] fine code

double dTotFine = 0d;
for(int i =0; i < vRetResult.size(); i += 8) {
	dTotFine = 0d;
	if(vRetResult.elementAt(i) != null) {
		for(int p =i; p < vRetResult.size(); p += 8) {
			dTotFine += ((Double)vRetResult.elementAt(p + 6)).doubleValue();
			if( (vRetResult.size() > (p + 9)) && vRetResult.elementAt(p + 9) != null)
				break;
		}
		%>
	<tr>
	  <td height="25" class="thinborderBOTTOMRIGHTDOTTED"><strong><%=(String)vRetResult.elementAt(i)%></strong></td>
	  <td class="thinborderBOTTOMRIGHTDOTTED"><strong><%=(String)vRetResult.elementAt(i + 1)%></strong></td>
	  <td class="thinborderBOTTOMRIGHTDOTTED" align="right"><strong>Total Overdue Fine</strong>&nbsp;</td>
	  <td class="thinborderBOTTOMRIGHTDOTTED" align="right"><strong><%=CommonUtil.formatFloat(dTotFine, true)%></strong></td>
	  <td align="center" class="thinborderBOTTOM">&nbsp;</td>
	</tr>
	<%}//show only if(vRetResult.elementAt(i) != null) {%> 
    <tr>
      <td height="25" class="thinborderRIGHTDOTTED"><%=WI.getStrValue(vRetResult.elementAt(i + 2), "&nbsp;")%></td>
      <td class="thinborderRIGHTDOTTED"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
      <td class="thinborderRIGHTDOTTED"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"@", "", "")%></td>
      <td align="right" class="thinborderRIGHTDOTTED"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 6)).doubleValue(), true)%></td>
      <td align="center" class="thinborderNONE"><%=vRetResult.elementAt(i + 7)%></td>
    </tr>
<%}//end of for loop.%>
  </table>
<%}//end of vRetResult if not null%>
<input type="hidden" name="pat_type_index">
<input type="hidden" name="search_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>