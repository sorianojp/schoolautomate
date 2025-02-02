<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
	this.SubmitOnce("dtr_op");
}	
function ReloadPage()
{
	document.dtr_op.print_page.value="";
	
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	this.SubmitOnce("dtr_op");
}

function ViewRecordDetail(index){
	document.dtr_op.print_page.value="";
	
	document.dtr_op.SummaryDetail.selectedIndex = 1;
	
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.emp_id.value=index;
	document.dtr_op.emp_type.value ="";
	document.dtr_op.c_index.value ="";
	document.dtr_op.d_index.value ="";
}
function ViewRecords()
{
	document.dtr_op.print_page.value="";	
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	this.SubmitOnce("dtr_op");
}


function PrintPage()
{
	document.dtr_op.print_page.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.reloadpage.value="1";
	this.SubmitOnce("dtr_op");
}

</script>
<body bgcolor="#D2AE72">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./dtr_print.jsp" />
<%}

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
    Vector vRetEDTR = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	int iIndex = 0;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","dtr_view.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"dtr_view.jsp");	
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
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};


ReportEDTR RE = new ReportEDTR(request);

 if (WI.fillTextValue("viewRecords").compareTo("1")==0){ 
	vRetResult = RE.searchEDTR(dbOP);
}

//added by biswa to get from and to date.
	String strDateFr = null;
	String strDateTo = null;
	if( WI.fillTextValue("DateDefaultSpecify").compareTo("0") == 0) {
		String[] astrTemp = eDTRUtil.getCurrentCutoffDateRange(dbOP, true);
		if(astrTemp != null) {
			strDateFr = astrTemp[0];
			strDateTo = astrTemp[1];
		}	
	}
	else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");
	}
%>

<form name="dtr_op" action="./dtr_view.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          DTR OPERATIONS - VIEW/PRINT DTR PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;
	<% if (WI.fillTextValue("window_opener").compareTo("1") == 0) {%>
		<div align="right">
			<a href="javascript:self.close();"><img src="../../../images/close_window.gif" border="0"></a>
		</div>
	<%}%>
	  </td>
    </tr>
	</table>
<% if (WI.fillTextValue("window_opener").compareTo("1") != 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="24">&nbsp;</td>
      <td width="17%" height="24">View/Print Type</td>
      <td height="24"><select name="SummaryDetail" onChange='ReloadPage();'>
          <option value=0>Summary</option>
          <% if (WI.fillTextValue("SummaryDetail").compareTo("1") == 0) { %>
          <option value=1 selected>Detail</option>
          <% }else{%>
          <option value=1>Detail</option>
          <%}%>
        </select></td>
      <td>Date 
        <select name="DateDefaultSpecify" onChange='ReloadPage();'>
          <option value="0" >Default cut-off date</option>
          <% if (WI.fillTextValue("DateDefaultSpecify").compareTo("1")==0){ %>
          <option value="1" selected>Specify date</option>
          <%}else{%>
          <option value="1">Specify date</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25">Enter Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="49%"> <% if (WI.fillTextValue("DateDefaultSpecify").compareTo("1")==0) {%>
        From 
        <input name="from_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("from_date")%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="to_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("to_date")%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <%}else{%> &nbsp; <%}%> </td>
    </tr>
<% if(WI.fillTextValue("print_by").compareTo("1") != 0){ %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF"> 
            <td width="18%" height="25">Employment Type</td>
            <td width="82%" height="25"> 
              <%strTemp2 = WI.fillTextValue("emp_type");%>
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%> 
              </select>
              </td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
                <option value="">N/A</option>
                <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";
%>
                <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"><%=strTemp2%></td>
            <td height="25"> <select name="d_index">
                <% if(strTemp.compareTo("") ==0){//only if from non college.%>
                <option value="">All</option>
                <%}else{%>
                <option value="">All</option>
                <%} strTemp3 = WI.fillTextValue("d_index");%>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25">Print DTR whose lastname starts with 
        <select name="lname_from" onChange="ReloadPage()">
<%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<28; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
<%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
<%}
}%>
        </select>
        to 
        <select name="lname_to">
          <option value="0"></option>
          <%
			 strTemp = WI.fillTextValue("lname_to");
			 
			 for(int i=++j; i<28; ++i){
			 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <%}//end of print by.
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><br> <a href="javascript:ViewRecords()"><img border="0" src="../../../images/form_proceed.gif"> </a>
      </td>
    </tr>
 </table>
<%} // end if (WI.fillTextValue("window_opener").compareTo("1") == 0)
 if (WI.fillTextValue("viewRecords").compareTo("1")==0){ 
	
	if (vRetResult!=null) {
	iSearchResult = RE.getSearchCount();
	int iPageCount = iSearchResult/RE.defSearchSize;
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;

if(iPageCount > 1) {//show this if page cournt > 1%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
	 <tr>
		  
      <td width="58%"><b>Total Result: <%=iSearchResult%> - Showing(<%=RE.getDisplayRange()%>)</b></td>
		  <td width="39%">Jump To page: 
		<select name="jumpto" onChange="goToNextSearchPage()">
 <%
	strTemp = request.getParameter("jumpto");
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
	for( int i =1; i<= iPageCount; ++i ){
	if(i == Integer.parseInt(strTemp) ){%>
		<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}else{%>
	   <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}
	} // end for loop
%>
		</select></td>
	  <td width="3%"><input name="image" type="image" src="../../../images/print.gif" align="right" width="58" height="26" onClick="PrintPage();"></td>
	</tr>
  </table>
 <%}//show jump page if page count > 1
 
 } // if ( PrintPage is not called.)
   %>

  <table width="100%" border="1" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="15" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">DTR 
          DETAILS (From <%=strDateFr%> to <%=strDateTo%>)</font></strong></div></td>
    </tr>
    <% 	
if (vRetResult!=null && vRetResult.size() > 0) {
	
	long lSubTotalWorkingHr = 0l;//sub total total working hour of employee.
	long lGTWorkingHr = 0l;//Total working hour of the employee for the specified date.
	long lOTHours = 0l; // Total OT hour for the day
	long lOTTotal = 0l; // Total OT Hours for the specified date

//as requestd, i have to show all the days worked and non worked.
Vector vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo);

  for (int i=0; i<vRetResult.size() ; i+=6){
	  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
	  strTemp = (String)vRetResult.elementAt(i+4);
	else strTemp += WI.getStrValue((String)vRetResult.elementAt(i+4),"/","",""); 
%>
    <tr > 
      <td height="25" colspan="15"><div align="left"><strong> <font size="1"><%=(String)vRetResult.elementAt(i)%></font><font color="#0000FF"> :: &nbsp;</font> <font size="1" color="#FF0000"><%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+1)%> </font> <font color="#0000FF"> :: &nbsp;</font> <font size="1"><%=strTemp%></font><font color="#0000FF"> :: &nbsp;</font> <font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></strong></div></td>
    </tr>
    <tr > 
      <td width="11%" height="25"><div align="center"><font size="1"><strong>DATE</strong></font></div></td>
      <td width="6%" align="center"><strong><font size="1">IN</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">LATE</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">OUT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">UT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">IN</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">LATE</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">OUT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">UT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">IN</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">LATE</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">OUT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">UT</font></strong></td>
      <td width="9%" align="center"><strong><font size="1">NO. OF HOURS</font></strong></td>
      <td width="8%" align="center"><div align="center"><font size="1"><strong>OVERTIME</strong></font></div></td>
    </tr>
    <%

vRetEDTR = RE.getDTRDetails(dbOP,(String)vRetResult.elementAt(i)); 
if (vRetEDTR == null || vRetEDTR.size() ==  0) { 
	strErrMsg=RE.getErrMsg();
}else{
	if (vRetEDTR.size() == 1){//non DTR employees
%>
    <tr> 
      <td height="25" colspan="15"> <div align="center"><strong><%=vRetEDTR.elementAt(0)%></strong></div></td>
    </tr>
    <%}else{
		strTemp3 = "";
		
		String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
		boolean bolDateRepeated = false;
		
	for(iIndex=0;iIndex<vRetEDTR.size();iIndex +=6){		
		strTemp =(String)vRetEDTR.elementAt(iIndex+4);
		
		if (strTemp!=null &&  (iIndex+6) < vRetEDTR.size() && 
		 strTemp.compareTo((String)vRetEDTR.elementAt(iIndex+10))==0){
			strTemp = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 8)).longValue(),2);
			strTemp2 = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 9)).longValue(),2);
		}
		else {
			strTemp =  null; 				
			strTemp2 = null;
		}
		if(strPrevDate.compareTo( (String)vRetEDTR.elementAt(iIndex+4) ) == 0) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}
		
			
//I ahve to display here for the days employee did not work. 
if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
	while(strPrevDate.compareTo((String)vDayInterval.elementAt(0)) != 0) {
	%>
    <tr> 
      <td height="19" class="thinborder" colspan="15" align="center" bgcolor="#CCDDDD"> 
        <%=(String)vDayInterval.remove(0)+":::"+(String)vDayInterval.remove(0)%></td>
    </tr>
    <%}//end of while looop
  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);vDayInterval.removeElementAt(0);
  }
  
}//end of if condition to print holidays.%>
    <tr> 
      <td height="25"><strong><font size="1"> 
        <%if(!bolDateRepeated){%>
        <%=(String)vRetEDTR.elementAt(iIndex+4)%> 
        <%}else{%>
        <%}%>
        </font></strong></td>
      <td><strong><font size="1"><%=WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2)%></font></strong></td>
      <td><strong></strong></td>
      <td><strong><font size="1"><%=WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2),"&nbsp;")%></font></strong></td>
      <td>&nbsp;</td>
      <td><strong><font size="1"><%=WI.getStrValue(strTemp,"&nbsp;")%></font></strong></td>
      <td>&nbsp;</td>
      <td><strong><font size="1"><%=WI.getStrValue(strTemp2,"&nbsp;")%></font></strong></td>
      <td width="6%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <%  // compute for the working hour for the day
					
		if(strTemp2 != null) iIndex += 6; 
		
		lSubTotalWorkingHr = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i), 
								(String)vRetEDTR.elementAt(iIndex+4));
		lOTHours = RE.getOTHours(dbOP,(String)vRetResult.elementAt(i),
								(String)vRetEDTR.elementAt(iIndex+4));
		if (lSubTotalWorkingHr < 0) lSubTotalWorkingHr = 0l;
		if (lOTHours < 0) lOTHours = 0l;
		
		if (strTemp3.compareTo((String)vRetEDTR.elementAt(iIndex+4)) !=0){
				strTemp3  = (String)vRetEDTR.elementAt(iIndex+4);
				lGTWorkingHr += lSubTotalWorkingHr;
				lOTTotal +=lOTHours;
		}else{
			lSubTotalWorkingHr = 0l;
		}
	%>
      <td width="9%"><strong><font size="1">&nbsp; 
        <%if(!bolDateRepeated){%>
        <%=CommonUtil.formatFloat(eDTRUtil.longHourToFloat(lSubTotalWorkingHr),true)%> 
        <%}%>
        </font></strong></td>
      <td width="8%"><strong><font size="1">&nbsp; 
        <%if(!bolDateRepeated){%>
        <%=CommonUtil.formatFloat(eDTRUtil.longHourToFloat(lOTHours),true)%> 
        <%}%>
        </font></strong></td>
    </tr>
    <% 
	  } // end for loop
	  

	  //I have to now print if there are any days having zero working hours.
	while(vDayInterval != null && vDayInterval.size() > 0) {
	%>
    <tr> 
      <td height="19" class="thinborder" colspan="15" align="center" bgcolor="#CCDDDD"> 
        <%=(String)vDayInterval.remove(0)+":::"+(String)vDayInterval.remove(0)%></td>
    </tr>
    <%  }//end of while looop
	 }
	} 
	%>
    <tr > 
      <td height="25" colspan="8"><div align="right"><font size="1"><strong>TOTAL 
          HOURS WORKED&nbsp;&nbsp;&nbsp;</strong></font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="center"><font size="2"><strong> <%=CommonUtil.formatFloat(eDTRUtil.longHourToFloat(lGTWorkingHr - lOTTotal),true)%></strong></font></div></td>
      <td><div align="center"><font size="2"><strong> <%=CommonUtil.formatFloat(eDTRUtil.longHourToFloat(lOTTotal),true)%></strong></font></div></td>
    </tr>
    <%
	lGTWorkingHr = 0l;
	lOTTotal = 0l;
	}
	 }%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25" colspan="6" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
	<tr > 
      <td height="25" colspan="6" bgcolor="#FFFFFF" align="right">
	  <a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
      </td>
    </tr>
</table>
<%}// end if(vRetEDTR == null || vRetEDTR.size() ==  0)%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>  
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>  
</table>


<input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
<input type=hidden name="viewRecords" value="0">
<input type=hidden name="print_page">
<input type=hidden name="window_operner" value="<%=WI.fillTextValue("window_opener")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>