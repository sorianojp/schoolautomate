
<!----- UPDATES 2013-03-26 ------->
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector,java.util.Calendar,java.text.*,java.util.Date " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>



<script language="JavaScript">
function submitForm() {
	document.form_.reloadPage.value='1';	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	
	document.getElementById('myID3').deleteRow(0);
	document.getElementById('myID3').deleteRow(0);
	
	document.getElementById('myID4').deleteRow(0);
	document.getElementById('myID4').deleteRow(0);
	
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
}


function UpdateCopyFor(){
	
	var strRemark = prompt("Provide Data for this copy","");
	if(strRemark.length == 0)
		return;
	
	document.getElementById('copy_for_').innerHTML = strRemark;
	
}	
</script>




<style type="text/css">
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>

</head>


<body bgcolor="#D2AE72">
<%
	String strTemp   = null;	
	String strErrMsg = null;
	String strTemp2  = null;
	int iNoOfDays = 3;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT","daily_enrollment_report.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"daily_enrollment_report.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

Vector vRetResult     	   = null;
Vector vCollegeList        = null;
Vector vPreviousData 	   = null;
Vector vPreviousDataOldNew = null;
Vector vComparisonOldNew   = null;
Vector vWithdrawnList      = null;
Vector vDailyEnrollment    = null;
Vector vPrevDailyEnrl      = null;
Vector vColumnDetail       = null;
Vector vAthlete 		   	= null;
Vector vNonAcad 		   	= null;
Vector vScholarTotal 	   = null;
Vector vPrevScholars 	   = null;
	 
ReportEnrollment reportEnrl = new ReportEnrollment();
if(WI.fillTextValue("reloadPage").length()>0){
	vRetResult = reportEnrl.getDailyEnrollment(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();	
}	


String[] strConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
String[] strConvertSem1 = {"SUM","1ST","2ND","3RD","4TH"};
	
%>
<form action="./daily_enrollment_report.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          DAILY ENROLLMENT REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">	
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%" height="25">School year </td>
      <td height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
      <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  
	  &nbsp; &nbsp;<select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>
	<tr>
		<td>&nbsp;</td>
		<td>Date Enrolled</td>
      	<td colspan="3"> 
<%
strTemp = WI.fillTextValue("date_from");
if(strTemp.length() == 0) {
	Calendar cal = Calendar.getInstance();	
	cal.setTime(ConversionTable.convertMMDDYYYYToDate(WI.getTodaysDate(1)));
	cal.add(Calendar.DATE, iNoOfDays - 5);
	strTemp = WI.formatDate(cal.getTime(),1);
}
%> 
	<input name="date_from" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.date_from');" 
		  	title="Click to select date" onMouseOver="window.status='Select date';return true;" 
			onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
		&nbsp; to &nbsp;
		
		<%
strTemp = WI.fillTextValue("date_to");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%> 
	<input name="date_to" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.date_to');" 
		  	title="Click to select date" onMouseOver="window.status='Select date';return true;" 
			onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>	
		</td>
	</tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
</table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){
		 
vCollegeList         = (Vector)vRetResult.remove(0);
vPreviousData 	      = (Vector)vRetResult.remove(0);
vPreviousDataOldNew  = (Vector)vRetResult.remove(0);
vComparisonOldNew    = (Vector)vRetResult.remove(0);
vWithdrawnList       = (Vector)vRetResult.remove(0);
vDailyEnrollment     = (Vector)vRetResult.remove(0);
vPrevDailyEnrl       = (Vector)vRetResult.remove(0);
vColumnDetail        = (Vector)vRetResult.remove(0);
vAthlete 			   = (Vector)vRetResult.remove(0);
vNonAcad 		  	   = (Vector)vRetResult.remove(0);
vScholarTotal 		   = (Vector)vRetResult.remove(0);
int iScholarNewTotal = 0;
int iScholarOldTotal = 0;

//vColumnDetail = new Vector();
//vColumnDetail.addElement(WI.fillTextValue("date_of_enrollment"));


if(vScholarTotal.size() > 1){
	iScholarOldTotal = Integer.parseInt(WI.getStrValue((String)vScholarTotal.remove(0),"0"));
	iScholarNewTotal = Integer.parseInt(WI.getStrValue((String)vScholarTotal.remove(0),"0"));
}
vPrevScholars 	 	= (Vector)vRetResult.remove(0);

//System.out.println("vPrevDailyEnrl "+vPrevDailyEnrl);
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
	<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a> 
		<font size="1">Click to print summary</font>		
	</td></tr><tr>
	<td height="15">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td valign="top" colspan="<%=vCollegeList.size() * 2 + 10%>">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
						<td width="50%" valign="top" class="thinborder">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable4">				
								<tr>
									<td width="20%" valign="top"> <img src="../../../../../images/logo/<%=strSchCode%>.gif" width="90" height="90" border="0"></td>
									<td width="80%" valign="top">
										<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
											<tr><td colspan="2"><font style="font-size:20px; font-style:italic; font-family:Cambria; font-weight:bold;">
											<%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></td></tr>							
											<tr><td height="20" style="font-size:12px;">
											<%if(strSchCode.startsWith("SWU")){%>Founded 1946 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%>
											<%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td></tr>
										</table>
								  </td>
								</tr>
						  </table>
						</td>
						<td class="thinborder" width="32%" align="center"><font style="font-size:20px; font-family:Cambria; font-weight:bold;">
							<i>Daily Enrollment Report</i><br>
						<%=strConvertSem[Integer.parseInt(WI.fillTextValue("semester"))].toUpperCase()%> <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></font></td>
						<td class="thinborder" width="18%" align="center" onClick="UpdateCopyFor()">COPY FOR: <br><br> <strong><label id="copy_for_"></label></strong></td>
					</tr>
				</table>
		</td>
	</tr>
	
	<%
int iTemp = 0;
int iNew = 0;
int iOld = 0;
int iTotal = 0;
int iSubTotal = 0;
int iSubTotalNew = 0;
int iSubTotalOld = 0;
String strSYFrom = null;
String strSYTo = null;
int iIndexOf = 0;
int iCountPerCell = 0;
int iPrevSYFrom = Integer.parseInt(WI.getStrValue(WI.fillTextValue("sy_from"),"0"));
for(int i = iPrevSYFrom - 4; i <= iPrevSYFrom - 1; i++){
		strSYFrom = Integer.toString(i);
		strSYTo   = Integer.toString(i + 1);
	%>
		<tr>
			<td height="17" class="thinborder"><%=strConvertSem1[Integer.parseInt(WI.fillTextValue("semester"))].toUpperCase()%> <%=strSYFrom+"-"+strSYTo%></td>
			<%
			  for(int j = 0; j < vCollegeList.size(); j+=2){
			  iCountPerCell =0;
			  if( (iIndexOf = vPreviousData.indexOf(vCollegeList.elementAt(j))) != -1) {			  	
				if( ((String)vPreviousData.elementAt(iIndexOf + 2)).compareTo(strSYFrom) == 0) {
					iCountPerCell = Integer.parseInt(WI.getStrValue((String)vPreviousData.elementAt(iIndexOf + 4),"0"));
					vPreviousData.remove(iIndexOf); vPreviousData.remove(iIndexOf); vPreviousData.remove(iIndexOf);
					vPreviousData.remove(iIndexOf); vPreviousData.remove(iIndexOf);
					
				}
			  }			  
			  %>
			  <td class="thinborder" colspan="2" align="right"><%=NumberFormat.getIntegerInstance().format(iCountPerCell)%></td>
			  <%}//show count here.%>
			  
			  <%
			  iNew = 0;
			  iOld = 0;
			 // iTotal = 0;
//			  for(int k = 0; k < vPreviousDataOldNew.size(); k+=4){
			  		iIndexOf = vPreviousDataOldNew.indexOf(strSYFrom+"_"+strSYTo);
					if(iIndexOf > -1){
						iNew = Integer.parseInt(WI.getStrValue((String)vPreviousDataOldNew.elementAt(iIndexOf+2),"0"));
						iOld = Integer.parseInt(WI.getStrValue((String)vPreviousDataOldNew.elementAt(iIndexOf+1),"0"));
					}
					
			  	  //if(((String)vPreviousDataOldNew.elementAt(k)).equals(strSYFrom)){
//				  	if(((String)vPreviousDataOldNew.elementAt(k+2)).equalsIgnoreCase("New"))
//						
//					else
//						
//				  }
				  iTotal = iNew + iOld;
			  //}
			  %>
			  <td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iOld)%></strong></td>
			  <td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iNew)%></strong></td>
			  <td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iTotal)%></strong></td>
		</tr>
	<%}%>
	
	
		<tr style="background-color:#999999;">
			<td class="thinborder" rowspan="2"><strong>DATE</strong></td>
			<%for(int j = 0; j < vCollegeList.size(); j+=2){%>
				<td class="thinborder" colspan="2" align="center" valign="top"><strong><%=vCollegeList.elementAt(j+1)%></strong></td>  
			<%}%>
			<td class="thinborder" align="center" colspan="3"><strong>OFFICIALLY<br>ENROLLED</strong></td>	
		</tr>
		<tr style="background-color:#999999;">		
			<%for(int j = 0; j < vCollegeList.size(); j+=2){%>
				<td height="17" class="thinborder" align="center" width="4%">OLD</td>  
				<td class="thinborder" align="center" width="4%">NEW</td>
			<%}%>
			<td class="thinborder" align="center" width="5%"><strong>OLD</strong></td>
			<td class="thinborder" align="center" width="5%"><strong>NEW</strong></td>
			<td class="thinborder" align="center" width="5%"><strong>TOTAL</strong></td>
		</tr>
		
		
		<!------ DAILY ENROLLMENT -------->
		
	<%	
	
	String strTotal = null;
	String strDate  = null;
	for(int i = 0; i < iNoOfDays; i++){
			iSubTotal = 0;
			iSubTotalNew = 0;
			iSubTotalOld = 0;
			if(vColumnDetail.size() > 0){
				strDate = (String)vColumnDetail.remove(0);//this is the date
				strTotal = "TOTAL";
			}else{
				strDate = "&nbsp;";
				strTotal = "&nbsp;";
			}
	%>
		<tr>
			<td height="17" class="thinborder" valign="top" rowspan="2"><%=strDate%></td>
			<%
				
			  for(int j = 0; j < vCollegeList.size(); j+=2){
			  	iNew = 0;
				iOld = 0;				
				
				iIndexOf = vDailyEnrollment.indexOf((String)vCollegeList.elementAt(j)+"_"+strDate);
				if(iIndexOf > -1){
					iNew = Integer.parseInt(WI.getStrValue((String)vDailyEnrollment.elementAt(iIndexOf + 2),"0"));
					iOld = Integer.parseInt(WI.getStrValue((String)vDailyEnrollment.elementAt(iIndexOf + 3),"0"));
				}
				
				/*
			  	for(int x = 0; x < vDailyEnrollment.size(); x+=5){
					if(((String)vDailyEnrollment.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){
						if( ((String)vDailyEnrollment.elementAt(x + 2)).compareTo(strTemp) == 0) {	
							if(((String)vDailyEnrollment.elementAt(x+3)).equalsIgnoreCase("New"))
								iNew = Integer.parseInt(WI.getStrValue((String)vDailyEnrollment.elementAt(x + 4),"0"));
							else
								iOld = Integer.parseInt(WI.getStrValue((String)vDailyEnrollment.elementAt(x + 4),"0"));														
						}
					}
				}
				*/
				
				
				/*iNew = 0;
			  	iOld = 0;
				iIndexOf = vDailyEnrollment.indexOf((String)vCollegeList.elementAt(j)+"_"+strDate);
				if(iIndexOf > -1){
					iNew = Integer.parseInt(WI.getStrValue((String)vDailyEnrollment.elementAt(iIndexOf + 2),"0"));
					iOld = Integer.parseInt(WI.getStrValue((String)vDailyEnrollment.elementAt(iIndexOf + 3),"0"));
				}*/
								
				// i update here the vPrevDailyEnrl to get the total every row.. vPrevDailyEnrl + vDailyEnrollment
				
				/*for aaron :: use this code*/
				iIndexOf = vPrevDailyEnrl.indexOf((String)vCollegeList.elementAt(j));
				if(iIndexOf > -1){
					//new
					iTemp = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 2),"0"));
					iTemp += iNew;
					vPrevDailyEnrl.setElementAt(Integer.toString(iTemp), iIndexOf + 2);	
					
					//old
					iTemp = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 3),"0"));
					iTemp += iOld;
					vPrevDailyEnrl.setElementAt(Integer.toString(iTemp), iIndexOf + 3);						
					
				}
				
				
			  	iSubTotalNew += iNew;
				iSubTotalOld += iOld;
				if(strTotal.equals("&nbsp;")){
					strTemp = "&nbsp;";
					strErrMsg = "&nbsp;";
				}else{
					strTemp = NumberFormat.getIntegerInstance().format(iOld);
					strErrMsg = NumberFormat.getIntegerInstance().format(iNew);
				}
			  %>			  
				<td height="17" valign="top" class="thinborder" align="right"><%=strTemp%></td>  
				<td class="thinborder" valign="top" align="right"><%=strErrMsg%></td>
			  <%}//show count here.
			  if(strTotal.equals("&nbsp;")){
					strTemp = "&nbsp;";
					strErrMsg = "&nbsp;";
					strTemp2 = "&nbsp;";
				}else{
					strTemp = NumberFormat.getIntegerInstance().format(iSubTotalOld);
					strErrMsg = NumberFormat.getIntegerInstance().format(iSubTotalNew);
					strTemp2 = NumberFormat.getIntegerInstance().format(iSubTotalOld + iSubTotalNew);
				}
			  %>
			  
			  <td class="thinborder" align="right"><strong><%=strTemp%></strong></td>
			  <td class="thinborder" align="right"><strong><%=strErrMsg%></strong></td>
			  <td class="thinborder" align="right"><strong><%=strTemp2%></strong></td>
		</tr>
		
		
		<tr>
			<%
			iSubTotal = 0;
			iSubTotalNew = 0;
			iSubTotalOld = 0;
			  for(int j = 0; j < vCollegeList.size(); j+=2){
			  	iNew = 0;
			  	iOld = 0;
				
				iIndexOf = vPrevDailyEnrl.indexOf((String)vCollegeList.elementAt(j));
				if(iIndexOf > -1){
					iNew = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 2),"0"));	
					iOld = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 3),"0"));
				}
				
				/*
				for(int x = 0; x < vPrevDailyEnrl.size(); x+=4){									
					if(((String)vPrevDailyEnrl.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
						if(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x+2)).equalsIgnoreCase("New"))
							iNew = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x + 3),"0"));
						else
							iOld = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x + 3),"0"));						
					}
				}
				*/
				
			  	iSubTotalNew += iNew;
				iSubTotalOld += iOld;
				if(strTotal.equals("&nbsp;")){
					strTemp = "&nbsp;";
					strErrMsg = "&nbsp;";
				}else{
					strTemp = NumberFormat.getIntegerInstance().format(iOld);
					strErrMsg = NumberFormat.getIntegerInstance().format(iNew);
				}
			  %>			  
				<td height="17" valign="top" class="thinborder" align="right"><%=strTemp%></td>  
				<td class="thinborder" valign="top" align="right"><%=strErrMsg%></td>
			  <%			  
			  }//show count here.
			  if(strTotal.equals("&nbsp;")){
					strTemp = "&nbsp;";
					strErrMsg = "&nbsp;";
					strTemp2 = "&nbsp;";
				}else{
					strTemp = NumberFormat.getIntegerInstance().format(iSubTotalOld);
					strErrMsg = NumberFormat.getIntegerInstance().format(iSubTotalNew);
					strTemp2 = NumberFormat.getIntegerInstance().format(iSubTotalOld + iSubTotalNew);
				}
			  %>
			  
			  <td class="thinborder" align="right"><strong><%=strTemp%></strong></td>
			  <td class="thinborder" align="right"><strong><%=strErrMsg%></strong></td>
			  <td class="thinborder" align="right"><strong><%=strTemp2%></strong></td>
		</tr>
		
		
		<tr>
			<td height="17" class="thinborder"><strong><%=strTotal%></strong></td>
			<%			
			for(int j = 0; j < vCollegeList.size(); j+=2){
				iTemp = 0;
				iNew = 0;
				iOld = 0;				
				
				iIndexOf = vPrevDailyEnrl.indexOf((String)vCollegeList.elementAt(j));
				if(iIndexOf > -1){
					iNew = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 2),"0"));	
					iOld = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 3),"0"));
					iTemp = iNew + iOld;	
				}
				
				/*
				for(int x = 0; x < vPrevDailyEnrl.size(); x+=4){														
					if(((String)vPrevDailyEnrl.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
						if(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x+2)).equalsIgnoreCase("New"))
							iNew = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x + 3),"0"));
						else
							iOld = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x + 3),"0"));
						iTemp = iNew + iOld;						
					}
				}	
				
				*/	
				
				if(strTotal.equals("&nbsp;"))
					strTemp = "&nbsp;";
				else
					strTemp = NumberFormat.getIntegerInstance().format(iTemp);					
				
			%>
				<td class="thinborder" colspan="2" align="center"><strong><%=strTemp%></strong></td>  
			<%}%>
			<td class="thinborder" align="right">&nbsp;</td>
			  <td class="thinborder" align="right">&nbsp;</td>
			  <td class="thinborder" align="right">&nbsp;</td>
		</tr>
		
		
	<%}%>
<!--</table>-->

<!--<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">-->
	<tr><td colspan="<%=vCollegeList.size() * 2 + 10%>" class="thinborder" valign="bottom" height="25"><strong>COMPARISON LAST YEAR (OLD AND NEW)</strong></td></tr>
<!--</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">-->
	<tr>
		<td class="thinborder"><strong>TOTAL</strong></td>
		<%
		iSubTotalNew = 0;
		iSubTotalOld = 0;
		for(int j = 0; j < vCollegeList.size(); j+=2){
			
			iNew = 0;
			iOld = 0;
//			for(int x = 0; x < vComparisonOldNew.size(); x+=4){
//				if(((String)vComparisonOldNew.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
//					if(((String)vComparisonOldNew.elementAt(x+3)).equalsIgnoreCase("New"))
//						iNew = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(x + 2),"0"));
//					else
//						iOld = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(x + 2),"0"));							
//				}
//			}
			iIndexOf = vComparisonOldNew.indexOf( (String)vCollegeList.elementAt(j) );
			if(iIndexOf > -1){
				iNew = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(iIndexOf + 3),"0"));
				iOld = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(iIndexOf + 2),"0"));		
			}

			iSubTotalNew += iNew;
			iSubTotalOld += iOld;
		%>
			<td height="17" class="thinborder" align="right" width="4%"><%=NumberFormat.getIntegerInstance().format(iOld)%></td>  
			<td class="thinborder" align="right" width="4%"><%=NumberFormat.getIntegerInstance().format(iNew)%></td>
		<%}%>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalOld)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalNew)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalOld + iSubTotalNew)%></strong></td>
	</tr>
<!--</table>-->



<!------- WITHDRAW ENROLLMENT ------>
<!--<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">-->
	<tr><td colspan="<%=vCollegeList.size() * 2 + 10%>" class="thinborder" valign="bottom" height="25"><strong>WITHDRAW ENROLLMENT</strong></td></tr>
<!--</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">-->
	<tr>
		<td class="thinborder">&nbsp;</td>
		<%		
		iSubTotalOld = 0;
		for(int j = 0; j < vCollegeList.size(); j+=2){		
			iOld = 0;
			iIndexOf = vWithdrawnList.indexOf(vCollegeList.elementAt(j));
			if(iIndexOf > -1)
				iOld = Integer.parseInt(WI.getStrValue((String)vWithdrawnList.elementAt(iIndexOf + 2),"0"));				
			
			/*
			for(int x = 0; x < vWithdrawnList.size(); x+=3){
				if(((String)vWithdrawnList.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j)))
					iOld = Integer.parseInt(WI.getStrValue((String)vWithdrawnList.elementAt(x + 2),"0"));								
				
			}*/
			//iSubTotalNew += iNew;
			iSubTotalOld += iOld;
		%>
			<td height="17" colspan="2" class="thinborder" align="center"><%=NumberFormat.getIntegerInstance().format(iOld)%></td>  			
		<%}%>
		<td class="thinborder" align="right" width="5%"><strong>&nbsp;</strong></td>
		<td class="thinborder" align="right" width="5%"><strong>&nbsp;</strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalOld)%></strong></td>
	</tr>
<!--</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">-->
	<tr>
		<td colspan="<%=vCollegeList.size() * 2 + 10%>" class="thinborder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">				
				<tr>
					<td width="26%" height="25" valign="bottom"><strong>WORKING SCHOLARS</strong></td>
					<td width="59%" valign="bottom">PREVIOUS STATISTICS ON WORKING SCHOLARS
						(<%=strConvertSem[Integer.parseInt(WI.fillTextValue("semester"))].toUpperCase()%> 
				  <%=(Integer.parseInt(WI.fillTextValue("sy_from")) - 1)+"-"+WI.fillTextValue("sy_from")%>)</td>
					
					<%
					iNew = 0;
					iOld = 0;
					for(int x = 0; x < vPrevScholars.size(); x+=2){
						if(((String)vPrevScholars.elementAt(x)).equalsIgnoreCase("New"))
							iNew = Integer.parseInt(WI.getStrValue((String)vPrevScholars.elementAt(x + 1),"0"));
						else
							iOld = Integer.parseInt(WI.getStrValue((String)vPrevScholars.elementAt(x + 1),"0"));
					}
					%>
					
					<td valign="bottom" class="" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iOld)%></strong></td>
					<td valign="bottom" class="" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iNew)%></strong></td>
					<td valign="bottom" class="" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iNew + iOld)%></strong></td>
				</tr>
			</table>
		</td>
	</tr>
	
<!--</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">-->
	<tr>
		<td class="thinborder"><strong>ATHLETE</strong></td>
		<%
		iSubTotalNew = 0;
		iSubTotalOld = 0;
		for(int j = 0; j < vCollegeList.size(); j+=2){
			
			iNew = 0;
			iOld = 0;
			for(int x = 0; x < vAthlete.size(); x+=4){
				if(((String)vAthlete.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
					if(((String)vAthlete.elementAt(x+2)).equalsIgnoreCase("New"))
						iNew = Integer.parseInt(WI.getStrValue((String)vAthlete.elementAt(x + 3),"0"));
					else
						iOld = Integer.parseInt(WI.getStrValue((String)vAthlete.elementAt(x + 3),"0"));								
				}
			}
			iSubTotalNew += iNew;
			iSubTotalOld += iOld;
		%>
			<td height="17" class="thinborder" align="right" width="4%"><%=NumberFormat.getIntegerInstance().format(iOld)%></td>  
			<td class="thinborder" align="right" width="4%"><%=NumberFormat.getIntegerInstance().format(iNew)%></td>
		<%}%>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalOld)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalNew)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalOld + iSubTotalNew)%></strong></td>
	</tr>
	<tr>
		<td class="thinborder"><strong>NON-ACADEMIC</strong></td>
		<%
		iSubTotalNew = 0;
		iSubTotalOld = 0;
		for(int j = 0; j < vCollegeList.size(); j+=2){
			
			iNew = 0;
			iOld = 0;
			for(int x = 0; x < vNonAcad.size(); x+=4){
				if(((String)vNonAcad.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
					if(((String)vNonAcad.elementAt(x+2)).equalsIgnoreCase("New"))
						iNew = Integer.parseInt(WI.getStrValue((String)vNonAcad.elementAt(x + 3),"0"));
					else
						iOld = Integer.parseInt(WI.getStrValue((String)vNonAcad.elementAt(x + 3),"0"));								
				}
			}
			iSubTotalNew += iNew;
			iSubTotalOld += iOld;
		%>
			<td height="17" class="thinborder" align="right" width="4%"><%=NumberFormat.getIntegerInstance().format(iOld)%></td>  
			<td class="thinborder" align="right" width="4%"><%=NumberFormat.getIntegerInstance().format(iNew)%></td>
		<%}%>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalOld)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalNew)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iSubTotalOld + iSubTotalNew)%></strong></td>
	</tr>
	<tr>
		<td height="17" class="thinborder" align="center"><strong>TOTAL WS</strong></td>
		<%
		iTemp = 0;
		for(int j = 0; j < vCollegeList.size(); j+=2){
			iTemp = 0;
			
			iIndexOf = vScholarTotal.indexOf(vCollegeList.elementAt(j));
			if(iIndexOf > -1)
				iTemp = Integer.parseInt(WI.getStrValue((String)vScholarTotal.elementAt(iIndexOf + 1),"0"));						
			/*
			for(int x = 0; x < vScholarTotal.size(); x+=2){														
				if(((String)vScholarTotal.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j)))
					iTemp = Integer.parseInt(WI.getStrValue((String)vScholarTotal.elementAt(x + 1),"0"));						
			}
			*/
			
		
		%>
			<td class="thinborder" colspan="2" align="center"><strong><%=NumberFormat.getIntegerInstance().format(iTemp)%></strong></td>  
		<%}%>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iScholarOldTotal)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iScholarNewTotal)%></strong></td>
		<td class="thinborder" align="right" width="5%"><strong><%=NumberFormat.getIntegerInstance().format(iScholarNewTotal + iScholarOldTotal)%></strong></td>
	</tr>
<!--</table>-->

<%
/////// adding the vPrevDailyEnrl + total scholars

Vector vGrandTotal = new Vector();
Vector vDifference = new Vector();

int iGrandTotNew = 0;
int iGrandTotOld = 0;

int iDiffNew = 0;
int iDiffOld = 0;

iSubTotalNew = 0;
iSubTotalOld = 0;

iTemp = 0;
int iDiff = 0;
for(int j = 0; j < vCollegeList.size(); j+=2){
	
	iTemp = 0;
	iCountPerCell = 0;
	iNew = 0;
	iOld = 0;
	iDiff = 0;
	
	
	iIndexOf = vPrevDailyEnrl.indexOf((String)vCollegeList.elementAt(j));
	if(iIndexOf > -1){
		iNew = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 2),"0"));	
		iOld = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(iIndexOf + 3),"0"));
		iTemp = iNew + iOld;	
	}
	/*
	for(int x = 0; x < vPrevDailyEnrl.size(); x+=4){														
		if(  ((String)vPrevDailyEnrl.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))  ){						
			if(  WI.getStrValue((String)vPrevDailyEnrl.elementAt(x+2)).equalsIgnoreCase("New")  )
				iNew = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x + 3),"0"));
			else
				iOld = Integer.parseInt(WI.getStrValue((String)vPrevDailyEnrl.elementAt(x + 3),"0"));
			iTemp = iNew + iOld;
		}
	}
	*/
	for(int x = 0; x < vNonAcad.size(); x+=4){
		if(((String)vNonAcad.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
			if(((String)vNonAcad.elementAt(x+2)).equalsIgnoreCase("New"))
				iNew += Integer.parseInt(WI.getStrValue((String)vNonAcad.elementAt(x + 3),"0"));
			else
				iOld += Integer.parseInt(WI.getStrValue((String)vNonAcad.elementAt(x + 3),"0"));								
		}
	}
	
	for(int x = 0; x < vAthlete.size(); x+=4){
		if(((String)vAthlete.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
			if(((String)vAthlete.elementAt(x+2)).equalsIgnoreCase("New"))
				iNew += Integer.parseInt(WI.getStrValue((String)vAthlete.elementAt(x + 3),"0"));
			else
				iOld += Integer.parseInt(WI.getStrValue((String)vAthlete.elementAt(x + 3),"0"));								
		}
	}
	
	
	iGrandTotNew += iNew;
	iGrandTotOld += iOld;
	
	iIndexOf = vScholarTotal.indexOf(vCollegeList.elementAt(j));
	if(iIndexOf > -1)
		iCountPerCell = Integer.parseInt(WI.getStrValue((String)vScholarTotal.elementAt(iIndexOf + 1),"0"));
	
	/*
	for(int x = 0; x < vScholarTotal.size(); x+=2){														
		if(((String)vScholarTotal.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){
			iCountPerCell = Integer.parseInt(WI.getStrValue((String)vScholarTotal.elementAt(x + 1),"0"));								
			vScholarTotal.setElementAt(Integer.toString(iIndexOf), x + 1);
		}	
	}
	*/

	vGrandTotal.addElement((String)vCollegeList.elementAt(j));
	vGrandTotal.addElement(Integer.toString(iCountPerCell + iTemp));
	
	iNew = 0;
	iOld = 0;
	//need this to get the difference.  calculation is iDiff = (working + current) - vComparisonOldNew
//	for(int x = 0; x < vComparisonOldNew.size(); x+=4){
//		if(((String)vComparisonOldNew.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j))){						
//			if(((String)vComparisonOldNew.elementAt(x+3)).equalsIgnoreCase("New"))
//				iNew = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(x + 2),"0"));
//			else
//				iOld = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(x + 2),"0"));
//				
//			iDiff = iNew + iOld;						
//		}
//	}

	iIndexOf = vComparisonOldNew.indexOf( (String)vCollegeList.elementAt(j) );
	if(iIndexOf > -1){
		iNew = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(iIndexOf + 3),"0"));
		iOld = Integer.parseInt(WI.getStrValue((String)vComparisonOldNew.elementAt(iIndexOf + 2),"0"));	
		iDiff = iNew + iOld;	
	}
	
	iSubTotalNew += iNew;
	iSubTotalOld += iOld;
	
	
	//iTemp = current enrolle, iCountPerCell == working student for current enroll. iDiff == previous enrolle
	iDiff = (iCountPerCell + iTemp) - iDiff; 
	
	
	vDifference.addElement((String)vCollegeList.elementAt(j));
	vDifference.addElement(Integer.toString(iDiff));
	

}

iDiffNew = iGrandTotNew - iSubTotalNew;
iDiffOld = iGrandTotOld - iSubTotalOld;

%>

<!-------  GRAND TOTAL ------>
<!--<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">-->
	<tr><td colspan="<%=vCollegeList.size() * 2 + 10%>" class="thinborder" valign="bottom" height="25">&nbsp;</td></tr>
<!--</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">-->
	<tr bgcolor="#999999">
		<td height="30" class="thinborder" align="center">GRAND<br>TOTAL</td>
		<%	
		for(int j = 0; j < vCollegeList.size(); j+=2){		
			iOld = 0;
			
			iIndexOf = vGrandTotal.indexOf(vCollegeList.elementAt(j));
			if(iIndexOf > -1){
				iOld = Integer.parseInt(WI.getStrValue((String)vGrandTotal.elementAt(iIndexOf + 1),"0"));
			}
			/*
			for(int x = 0; x < vGrandTotal.size(); x+=2){
				if(((String)vGrandTotal.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j)))
					iOld = Integer.parseInt(WI.getStrValue((String)vGrandTotal.elementAt(x + 1),"0"));								
				
			}*/
		%>
			<td height="17" class="thinborder" colspan="2" align="center"><strong><%=NumberFormat.getIntegerInstance().format(iOld)%></strong></td>  			
		<%}%>
		<td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iGrandTotOld)%></strong></td>
		<td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iGrandTotNew)%></strong></td>
		<td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iGrandTotNew + iGrandTotOld)%></strong></td>
	</tr>
<!--</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">-->
	<tr><td class="thinborder" colspan="<%=vCollegeList.size() * 2 + 10%>" valign="bottom" height="25">DIFFERENCE COMPARED TO 
		<%=strConvertSem[Integer.parseInt(WI.fillTextValue("semester"))].toUpperCase()%> 
		<%=(Integer.parseInt(WI.fillTextValue("sy_from")) - 1)+"-"+WI.fillTextValue("sy_from")%></td></tr>
<!--</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder"-->
	<tr bgcolor="#999999">
		<td height="30" class="thinborder" align="center">DIFFERENCE</td>
		<%	
		for(int j = 0; j < vCollegeList.size(); j+=2){		
			iOld = 0;
			
			iIndexOf = vDifference.indexOf(vCollegeList.elementAt(j));
			if(iIndexOf > -1){
				iOld = Integer.parseInt(WI.getStrValue((String)vDifference.elementAt(iIndexOf + 1),"0"));
			}
			/*
			for(int x = 0; x < vDifference.size(); x+=2){
				if(((String)vDifference.elementAt(x)).equalsIgnoreCase((String)vCollegeList.elementAt(j)))
					iOld = Integer.parseInt(WI.getStrValue((String)vDifference.elementAt(x + 1),"0"));
			}*/
		%>
			<td height="17" class="thinborder" align="center" colspan="2"><strong><%=NumberFormat.getIntegerInstance().format(iOld)%></strong></td>  			
		<%}%>
		<td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iDiffOld)%></strong></td>
		<td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iDiffNew)%></strong></td>
		<td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(iDiffOld + iDiffNew)%></strong></td>
	</tr>
<!--</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">-->
	<tr><td colspan="<%=vCollegeList.size() * 2 + 10%>" class="thinborder" height="2" align="right" style="padding-right:200px;"><font style="font-size:7px;"><%=WI.getTodaysDateTime()%></font></td></tr>
</table>
<%}//end vRetResult%>
	
	
	
  
  
  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="no_of_days" value="<%=iNoOfDays%>">
<input type="hidden" name="reloadPage">
</form>


<!-- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>