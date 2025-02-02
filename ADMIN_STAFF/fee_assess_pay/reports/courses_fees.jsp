<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder{
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }



    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-right: dotted 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderTOPBOTTOMLEFT {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/formatFloat.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.coursefee.submit();
}
function ViewInfo()
{

	document.coursefee.view_info.value = 1;
	document.coursefee.submit();
}
function ReloadCourseIndex()
{
	document.coursefee.view_info.value = 0;
	//course index is changed -- so reset all dynamic fields.
	if(document.coursefee.sy_from.selectedIndex > -1)
		document.coursefee.sy_from[document.coursefee.sy_from.selectedIndex].value = "";
	if(document.coursefee.major_index.selectedIndex > -1)
		document.coursefee.major_index[document.coursefee.major_index.selectedIndex].value = "";

	document.coursefee.course_name.value = document.coursefee.course_index[document.coursefee.course_index.selectedIndex].text;
	document.coursefee.submit();
}
//calculate here the fee and load selected.
function ShowTutionFee(chkboxName,subAmount,subLoad)
{
	var vTemp;
	if( eval('document.coursefee.'+chkboxName+'.checked'))
	{
		vTemp = eval(document.coursefee.tot_load.value) + eval(subLoad);
		document.coursefee.tot_load.value = vTemp;
		vTemp = eval(document.coursefee.tot_tut_fee_actual.value) + eval(subAmount);
		document.coursefee.tot_tut_fee_actual.value = truncateFloat(vTemp,4,true);//.toFixed(3);

		//now format the actual value to approx value for display.
		document.coursefee.tot_tut_fee.value = truncateFloat(document.coursefee.tot_tut_fee_actual.value,3,false);//.toFixed(3);
	}
	else
	{
		vTemp = eval(document.coursefee.tot_load.value) - eval(subLoad);
		document.coursefee.tot_load.value = vTemp;
		vTemp = eval(document.coursefee.tot_tut_fee_actual.value) - eval(subAmount);
		document.coursefee.tot_tut_fee_actual.value = truncateFloat(vTemp,4,true);//.toFixed(3);

		//now format the actual value to approx value for display.
		document.coursefee.tot_tut_fee.value = truncateFloat(document.coursefee.tot_tut_fee_actual.value,3,false);//.toFixed(3);
	}
}
function ChangeCurYear() {
	var curYrTo = document.coursefee.cy_from.selectedIndex;
	curYrTo = eval('document.coursefee.cy_to'+curYrTo+'.value');
//	alert(curYrTo);
	document.coursefee.cy_to.value = curYrTo;
	this.ReloadPage();
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.NAGeneralLink,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	boolean bolDisplayFee = false;
	String strCourseIndex 	= request.getParameter("course_index");
	String strCourseName 	= request.getParameter("course_name");
	String strMajorIndex 	= request.getParameter("major_index");

	String strSYFrom 		= request.getParameter("cy_from");
	String strSYTo = null; // this is used in

	int i = -1;
	int j=0;

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


String strSchCode = WI.getStrValue(dbOP.getSchoolIndex());

if(request.getParameter("view_info") != null && request.getParameter("view_info").compareTo("1") ==0)
	bolDisplayFee = true;
//end of security code.
strErrMsg = null; //if there is any message set -- show at the bottom of the page.

Vector vTuitionFee = new Vector(); Vector vEnrlDateParam = null;
Vector vTemp = new Vector();

NAGeneralLink gLink = new NAGeneralLink();

if(bolDisplayFee)
{
	vTuitionFee = gLink.getCourseFeeDtlsNew(dbOP, request);//get Tution fee detail.
	if(vTuitionFee == null)
		strErrMsg = gLink.getErrMsg();
}//display if page is reloaded.
SubjectSection SS = new SubjectSection();
String[] astrSchYrInfo = dbOP.getCurSchYr();

%>
<form name="coursefee" action="./courses_fees.jsp" method="post">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F">
      <td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>::
        COURSE FEE::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="20" colspan="3">&nbsp;</td>
    </tr>
	<tr>
      <td height="25" width="2%">&nbsp;</td>
	  <td width="52%">Course</td>
	  <td width="46%"><font size="1">Curriculum Year (new applicant, pls select latest CY)</font></td>
    </tr>

    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2" valign="middle">
<select name="course_index" onChange="ReloadCourseIndex();">
          <option value="0">Select Any</option>
<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", strCourseIndex, false)%>
        </select>    </td>
    </tr>
  <tr>
      <td height="25" width="2%">&nbsp;</td>
	  <td width="52%">Major&nbsp;
<select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
          <%}%>
      </select></td>
	  <td width="46%">Cur. Year:
        <select name="cy_from" onChange="ChangeCurYear();">
          <%
	vTemp = SS.getSchYear(dbOP, request, true);
	strTemp = WI.fillTextValue("cy_from");

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%> - <%=(String)vTemp.elementAt(i + 1)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%> - <%=(String)vTemp.elementAt(i + 1)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0) {
	strSYTo = (String)vTemp.elementAt(j+1);		
}
else
	strSYTo = "";

%>
        </select>
        <!--to <b><%=strSYTo%></b>-->
        <input type="hidden" name="cy_to" value="<%=strSYTo%>">
        <%for(i = 0,j=0; i< vTemp.size(); i += 2, ++j) {%>
        <input type="hidden" name="cy_to<%=j%>" value="<%=(String)vTemp.elementAt(i + 1)%>">
      <%}%></td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="7%" valign="middle">Year      </td>
      <td width="11%" valign="middle">
        <select name="year_level">
		<option value="1">1st</option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("2") == 0){%>
		<option value="2" selected>2nd</option>
<%}else{%><option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
		<option value="3" selected>3rd</option>
<%}else{%><option value="3">3rd</option>
<%}if(strTemp.compareTo("4") ==0){%>
		<option value="4" selected>4th</option>
<%}else{%>
		<option value="4">4th</option>
<%}if(strTemp.compareTo("5") ==0){%>
		<option value="5" selected>5th</option>
<%}else{%><option value="5">5th</option>
<%}if(strTemp.compareTo("6") ==0){%>
		<option value="6" selected>6th</option>
<%}else{%>
		<option value="6">6th</option>
<%}%>   </select>      </td>
      <td width="37%" valign="middle" >SY-Term
<%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('coursefee','sy_from','sy_to');">
        <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
-
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
<select name="semester">
  <option value="1">1st</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("2")){%>
  <option value="2" selected>2nd</option>
  <%}else{%>
  <option value="2">2nd</option>
  <%}
  if (!strSchCode.startsWith("CPU")){
  
  if(strTemp.equals("3")){%>
  <option value="3" selected>3rd</option>
  <%}else{%>
  <option value="3">3rd</option>
  <%}
  }
  if(strTemp.equals("0")){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select></td>
      <td width="43%" valign="middle" ><input name="image" type="image" onClick="ViewInfo();" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" valign="middle">
<%
strTemp = WI.fillTextValue("is_old");
if(strTemp.length() > 0)
	strTemp = " checked";
else
	strTemp = "";
%> 	  <input type="checkbox" name="is_old" value="1"<%=strTemp%>>
      <font style="font-size:13px; color:#0000FF; font-weight:bold">Old student? </font>&nbsp;&nbsp;&nbsp;
	  <br><br>Note: Fee may change in actual assessment
	  
	  
	  </td>
    </tr>
    
<%
//display if there is any error and on error do not display anything else
if(strErrMsg != null)
{%>
    <tr valign="top">
	<td>&nbsp;</td>
      <td height="25" colspan="4"><br><strong><%=strErrMsg%></strong></td>
    </tr>

    <tr valign="top">
      <td height="25" colspan="5" ><hr size="1"></td>
    </tr>
  </table>
<%}else if(bolDisplayFee && vTuitionFee != null && vTuitionFee.size() > 0){%>
<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F">
      <td height="25" align="center" bgcolor="#BECED3"><strong>:: ESTIMATED FEE :: </strong></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold;" bgcolor="#DDDDDD" align="center">
	  <td width="12%" class="thinborderTOPBOTTOMLEFT" height="22">Subject Code </td>
      <td width="38%" class="thinborderTOPBOTTOMLEFT">Subject Name </td>
      <td width="7%" class="thinborderTOPBOTTOMLEFT">Lec/Lab Unit </td>
      <td width="8%" class="thinborderTOPBOTTOMLEFT">Subj Fee </td>
      <td width="10%" class="thinborderTOPBOTTOMLEFT">Lab Fee/ Hands On Fee </td>
      <td width="10%" class="thinborderALL">Total Subject Fee </td>
    </tr>
<%
vEnrlDateParam = (Vector)vTuitionFee.remove(0);
double dTotalAssessment = Double.parseDouble((String)vTuitionFee.remove(0));
String strTotAssessment = CommonUtil.formatFloat(dTotalAssessment, true);
strTotAssessment = ConversionTable.replaceString(strTotAssessment, ",","");
dTotalAssessment = Double.parseDouble(strTotAssessment);

vTuitionFee.removeElementAt(0);
double dSubTuition = 0d;
double dSubMiscFee = 0d;
double dLecLabUnit = 0d;
double dTotUnit    = 0d;
for(i = 0,j=0; i< vTuitionFee.size(); i += 12,++j)
{
dSubTuition = Double.parseDouble((String)vTuitionFee.elementAt(i + 10));
dSubMiscFee = ((Double)vTuitionFee.elementAt(i + 11)).doubleValue();
dLecLabUnit = Double.parseDouble((String)vTuitionFee.elementAt(i + 6)) + 
					Double.parseDouble((String)vTuitionFee.elementAt(i + 7));
dTotUnit += dLecLabUnit;
%>
    <tr>
	<td class="thinborder" height="20"><%=(String)vTuitionFee.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vTuitionFee.elementAt(i+3)%></td>
      <td align="center" class="thinborder"><%=(String)vTuitionFee.elementAt(i+6)%>/<%=(String)vTuitionFee.elementAt(i+7)%> </td>
      <td align="center" class="thinborder"><%=CommonUtil.formatFloat(dSubTuition, true)%></td>
      <td align="center" class="thinborder"><%=CommonUtil.formatFloat(dSubMiscFee, true)%></td>
      <td align="center" class="thinborder"><%=CommonUtil.formatFloat(dSubTuition + dSubMiscFee, true)%></td>
    </tr>
<%}%>
    <tr>
      <td colspan="6" height="25"><div align="center">TOTAL LOAD UNITS :
	  <input type="text" name="tot_load" value="<%=dTotUnit%>" readonly="yes" size="4" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></div></td>
    </tr>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%"><strong><font size="1">TOTAL ASSESSMENT  </font></strong></td>
      <td width="72%"><strong><font size="1">Php &nbsp;
	  <input type="text" name="tot_tut_fee" value="<%=dTotalAssessment%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:9px;"> 
	  (total tuition + misc + other charges)</font></strong></td>
      <input type="hidden" name="tot_tut_fee_actual" value="<%=dTotalAssessment%>">
	  <td width="5%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <%if(gLink.vGenericInfo != null && gLink.vGenericInfo.size() > 0) {
	  	String strTotOthCharge = (String)gLink.vGenericInfo.remove(0);
	  	String strTotMiscFee   = (String)gLink.vGenericInfo.remove(0);
	  %>
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="49%" valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
						<tr>
							<td align="center" style="font-weight:bold;" colspan="2" bgcolor="#CCCCCC" class="thinborder">Misc Fee Details</td>
						</tr>
						<tr style="font-weight:bold" align="center" bgcolor="#FFFFCC">
							<td width="72%" class="thinborder">Fee Name</td>
							<td width="28%" class="thinborder">Amount</td>
						</tr>
						<%while(gLink.vGenericInfo.size() > 0) {
							if(gLink.vGenericInfo.elementAt(2).equals("1"))
								break;
						%>
						<tr>
							<td height="20" class="thinborder"><%=gLink.vGenericInfo.remove(0)%></td>
							<td class="thinborder" align="right"><%=gLink.vGenericInfo.remove(0)%></td>
						</tr>
						<%gLink.vGenericInfo.remove(0);}//end of showing misc fee.%>
					  <tr>
						  <td height="20" colspan="2" class="thinborder" align="right" style="font-weight:bold">Total: <%=strTotMiscFee%></td>
					  </tr>
						
					</table>
				</td>
				<td width="2%">&nbsp;</td>
				<td width="49%" valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
						<tr>
							<td align="center" style="font-weight:bold;" colspan="2" bgcolor="#CCCCCC" class="thinborder">Other Charges Details</td>
						</tr>
						<tr style="font-weight:bold" align="center" bgcolor="#FFFFCC">
							<td width="72%" class="thinborder">Fee Name</td>
							<td width="28%" class="thinborder">Amount</td>
						</tr>
						<%while(gLink.vGenericInfo.size() > 0) {%>
						<tr>
							<td height="20" class="thinborder"><%=gLink.vGenericInfo.remove(0)%></td>
							<td class="thinborder" align="right"><%=gLink.vGenericInfo.remove(0)%></td>
						</tr>
						<%gLink.vGenericInfo.remove(0);}//end of showing misc fee.%>
					  <tr>
						  <td height="20" colspan="2" class="thinborder" align="right" style="font-weight:bold">Total: <%=strTotOthCharge%></td>
					  </tr>
						
					</table>				
				</td>
			</tr>
		</table>
	  
	  <%}%>
	  </td>
      <td>&nbsp;</td>
    </tr>
<%if(vEnrlDateParam != null && vEnrlDateParam.size() > 0) {%>
   <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" align="center">&nbsp;
		  <table border="0" width="95%" cellpadding="0" cellspacing="0" class="thinborderALL" bgcolor="#DDDDDD">
			<%for(i =0; i < vEnrlDateParam.size(); i += 10){
				//to get date range.
				strTemp = (String)vEnrlDateParam.elementAt(i+1);
				if(strTemp == null) {//it is having date range.
					if(vEnrlDateParam.elementAt(i+2) != null && vEnrlDateParam.elementAt(i + 3) != null && vEnrlDateParam.elementAt(i + 4) != null)
						strTemp = (String)vEnrlDateParam.elementAt(i+2)+" " +(String)vEnrlDateParam.elementAt(i+3)+
									" days of "+(String)vEnrlDateParam.elementAt(i+4);
					else
						strTemp = "&nbsp;";
				}
				%>			
			  <tr>
			    <td class="thinborderBOTTOMRIGHT"><%=vEnrlDateParam.elementAt(i)%></td>
			    <td class="thinborderBOTTOMRIGHT"><%=strTemp%></td>
			    <td class="thinborderBOTTOMRIGHT">
					<%
					strTemp = "";
					if(vEnrlDateParam.elementAt(i+5) != null)
						strTemp = (String)vEnrlDateParam.elementAt(i+5)+" - " ;
					if(vEnrlDateParam.elementAt(i+6) != null)
						strTemp +=	CommonUtil.formatFloat((String)vEnrlDateParam.elementAt(i+6),true);
					if(vEnrlDateParam.elementAt(i+7) != null)
						strTemp += (String)vEnrlDateParam.elementAt(i+7);
					if(vEnrlDateParam.elementAt(i+8) != null)
						strTemp += " - "+(String)vEnrlDateParam.elementAt(i+8);
					strTemp = WI.getStrValue(strTemp, "&nbsp;");
					%>				
					<%=strTemp%></td>
			    <td class="thinborderBOTTOM"><%=WI.getStrValue(vEnrlDateParam.elementAt(i+9),"&nbsp;")%></td>
		    </tr>
			<%}%>
		  </table>	  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
  </table>

<%
}// showing if there is no error in getting fee information.
%>
  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" colspan="2">&nbsp;</td>
    </tr>

    <tr>
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="course_name" value="<%=request.getParameter("course_name")%>">
<input type="hidden" name="view_info" value="0">
<input type="hidden" name="major_name" value="">
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
