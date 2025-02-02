<%@ page language="java" import="utility.*,enrollment.SubjectSectionCPU,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SUBJECT SECTION MAINTENANCE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
a {
	text-decoration:none;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}

function EditStubCode(strInfoIndex){

	var loadPg = "./sched_edit.jsp?stub_code="+strInfoIndex+"&opner_form_name=form_";
	var win=window.open(loadPg,"newWin",'dependent=yes,width=650,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function updateRowPerPage(iRowPPg){
	if (iRowPPg == 2){
		document.form_.row_ppg.selectedIndex = document.form_.row_ppg2.selectedIndex;
	}else{
		document.form_.row_ppg2.selectedIndex = document.form_.row_ppg.selectedIndex;
	}
}

</script>

<body bgcolor="#D2AE72">
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./gen_sched_print.jsp" />
<%}
	
	String strErrMsg = null;
	String strTemp = null;
	String strTempIndex = null;
	String[] astrDay = {"S","M","T","W","TH","F","SAT"};
	String[] astrAMPM = {"AM", "PM"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-edit subject section","edit_section.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"gen_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

SubjectSectionCPU subSecCPU = new SubjectSectionCPU();
Vector vRetResult = null;
String[]  astrConvSemester ={"Summer", "First Semester", "Second Semester"};


//get all levels created.
vRetResult =	subSecCPU.getOfferingPerCollege(dbOP,request, null,null);
if((vRetResult == null || vRetResult.size() ==0) && strErrMsg == null)
	strErrMsg = subSecCPU.getErrMsg();
if(strErrMsg == null) strErrMsg = "";


float fTemp24HF = 0f;
float fTemp24HT = 0f;
int[] iTimeDataFr = null;
int[] iTimeDataTo = null;
String strTempDay = "";
String strTempRoom = "";
String strTempCol = null;
String strTempDept = null;
String strTempSub = null;
boolean bIsDupe = false;
boolean bResetSub = true;
String str12AMList = "";

%>
<form name="form_" method="post" action="./gen_sched.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          GENERAL SCHEDULE OF CLASSES ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td colspan="6" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="24%">Offering School Year/Term</td>
      <td width="32%"> 
        <%
        strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
        %> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%strTemp = WI.fillTextValue("sy_to");
        if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;<%
        strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0 )
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
        %> <select name="semester">
          <option value="0">Summer</option>
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}%>
        </select></td>
      <td width="42%" align="left"><a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
<% strTemp = WI.fillTextValue("c_index");

	if (strTemp.length() > 0) 
		strTemp = " c_index = " + strTemp;
	else
		strTemp = "((c_index is not null and c_index <> 0)  or d_code ='NSTP')";
		
	strTemp = dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 " +
		  			" and " + strTemp + 
					" order by d_name asc", WI.fillTextValue("d_index"), false);
	if (strTemp.length() > 0) {
%>
 <% }
 
 if (vRetResult!= null && vRetResult.size()>0){
       strTemp = WI.fillTextValue("row_ppg");%>
<%}%>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="26">&nbsp;</td>
      <td width="18%">Offered by College : </td>
      <td width="80%" colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">Select College</option>
          <%=dbOP.loadCombo("c_index","c_name",
		  " from college where IS_DEL=0 order by c_name asc",WI.fillTextValue("c_index"), false)%>
      </select></td>
    </tr>
    <% strTemp = WI.fillTextValue("c_index");

	if (strTemp.length() > 0) 
		strTemp = " c_index = " + strTemp;
	else
		strTemp = "((c_index is not null and c_index <> 0)  or d_code ='NSTP')";
		
	strTemp = dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 " +
		  			" and " + strTemp + 
					" order by d_name asc", WI.fillTextValue("d_index"), false);
	if (strTemp.length() > 0) {
%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Offered by Dept : </td>
      <td colspan="2"><select name="d_index">
          <option value="">--</option>
          <%=strTemp%>
        </select>      </td>
    </tr>
    <% } %>
 

    <tr>
      <td height="25">&nbsp;</td>
      <td>Status : </td>
      <td colspan="2">
        <select name="sub_stat">
		<option value=""> ALL </option>
		<% if (WI.fillTextValue("sub_stat").equals("100")) {%> 
		<option value="100" selected>General Schedule of Classes</option>
		<%}else{%> 
		<option value="100">General Schedule of Classes</option>
		<%}%>
		<%=dbOP.loadCombo("status_index","status",
		  					" from e_sub_status order by status_index asc",
							WI.fillTextValue("sub_stat"), false)%> </select> </td>
    </tr>
<%
 if (vRetResult!= null && vRetResult.size()>0){
       strTemp = WI.fillTextValue("row_ppg");%>	
    <tr>
      <td height="35">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" align="right"><font size="1">Rows per page</font>&nbsp;
          <select name="row_ppg" style="font-size:11px" onChange="updateRowPerPage(1)">
            <option value="25">25</option>
            <%if (strTemp.equals("30")) {%>
            <option value="30" selected>30</option>
            <%} else {%>
            <option value="30">30</option>
            <%} if (strTemp.equals("35")) {%>
            <option value="35" selected>35</option>
            <%} else {%>
            <option value="35">35</option>
            <%} if (strTemp.equals("40")) {%>
            <option value="40" selected>40</option>
            <%} else {%>
            <option value="40">40</option>
            <%} if (strTemp.equals("45")) {%>
            <option value="45" selected>45</option>
            <%} else {%>
            <option value="45">45</option>
            <%} if (strTemp.equals("50")) {%>
            <option value="50" selected>50</option>
            <%} else {%>
            <option value="50">50</option>
            <%} if (strTemp.equals("55")) {%>
            <option value="55" selected>55</option>
            <%} else {%>
            <option value="55">55</option>
            <%} %>
          </select>
        &nbsp;&nbsp; <a href="javascript:PrintPage()"><img src="../../../../images/print.gif" border="0"></a> &nbsp; </td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border=0 bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF"><strong>C P U - General Schedule of Classes for 
      <%=astrConvSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"1"))]  + " " + 
	  		WI.getStrValue(request.getParameter("sy_from"),"&nbsp;") +" - "+ 
			WI.getStrValue(request.getParameter("sy_to"),"&nbsp;")%></strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
    
    strTempCol = (String)vRetResult.elementAt(0);
	strTempDept = (String)vRetResult.elementAt(2);
	strTempSub = (String)vRetResult.elementAt(4);
	int iCtr = 0; 
for(int i = 0 ; i < vRetResult.size() ; i+=22) {
	strTempIndex = (String)vRetResult.elementAt(i+6);
	if (i>0 && strTempIndex.equals((String)vRetResult.elementAt(i-16)))
		bIsDupe = true;
	else
		bIsDupe = false;
	
	
	if (i==0 || 
	!(
		((strTempCol == null && vRetResult.elementAt(i)==null) ||
		(strTempCol != null && vRetResult.elementAt(i)!=null && strTempCol.equals((String)vRetResult.elementAt(i)))) &&
	((strTempDept == null && vRetResult.elementAt(i+2)==null) ||
	(strTempDept != null && vRetResult.elementAt(i+2)!=null && strTempDept.equals((String)vRetResult.elementAt(i+2))))
	))
	{%>
	<tr>
		<td colspan="10" height="10">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="10" height="25"><u><strong><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"",
		WI.getStrValue((String)vRetResult.elementAt(i+3)," - ","",""),WI.getStrValue((String)vRetResult.elementAt(i+3),"","","&nbsp;"))%></strong></u></td>
	</tr>
	<%
	    strTempCol = (String)vRetResult.elementAt(i);
		strTempDept = (String)vRetResult.elementAt(i+2);
		bResetSub = true;
		}
	
	if ( i== 0 || !(strTempSub.equals((String)vRetResult.elementAt(i+4))) || bResetSub){%>
	<tr>
		<td colspan="10" height="10">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="10" height="25"><strong><%=(String)vRetResult.elementAt(i+4) + " - " + (String)vRetResult.elementAt(i+5)%></strong></td>
	</tr>
	<%
	strTempSub = (String)vRetResult.elementAt(i+4);
	bResetSub = false;
	}%>
    <tr>
<%	 
	if (((String)vRetResult.elementAt(i+16)).equals("1"))
		strTemp = " Lab";
	else
		strTemp ="";

	if (!bIsDupe){
		strTemp = (String)vRetResult.elementAt(i+4) + strTemp;
	}else{
		strTemp = "&nbsp;";
	}
	
	if (strTemp.length() > 13)
		strTemp = strTemp.substring(0,13);
%>
      <td width="14%" height="20"><font size="1"><%=strTemp%></font></td>
<%if (bIsDupe) 
	  	strTemp = "&nbsp;";
	else
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;");
	if (strTemp.equals("*")) strTemp="&nbsp;";
	
	if (strTemp.length() > 20) 
		strTemp = strTemp.substring(0,20);
%>	  
      <td width="18%"><font size="1"><%=strTemp%></font>	  </td>
      <%
		strTempDay = "";
		strTempRoom = WI.getStrValue((String)vRetResult.elementAt(i+15),"TBA");

	if (vRetResult.elementAt(i+8)!=null && vRetResult.elementAt(i+9) != null)
    {			
    	strTempDay = astrDay[Integer.parseInt((String)vRetResult.elementAt(i+10))];
    	fTemp24HF = Float.parseFloat((String)vRetResult.elementAt(i+8));
	    fTemp24HT = Float.parseFloat((String)vRetResult.elementAt(i+9));
		
	    iTimeDataFr = comUtil.convert24HRTo12Hr(fTemp24HF);
		if (iTimeDataFr != null && (iTimeDataFr[2]  == 1) && (iTimeDataFr[0] < 12)){
	
			iTimeDataFr[0] +=12;
		}
			
	    iTimeDataTo = comUtil.convert24HRTo12Hr(fTemp24HT);
		if (iTimeDataTo != null && (iTimeDataTo[2]  == 1) && (iTimeDataTo[0] < 12)){
			iTimeDataTo[0] +=12;
		}
		
		if (iTimeDataFr == null || iTimeDataTo == null){
			if (str12AMList.length() == 0)
				str12AMList = "<a href=\"javascript:EditStubCode(" + 
							(String)vRetResult.elementAt(i+6) + ")\">" + 
							(String)vRetResult.elementAt(i+6) + "</a>";
			else
				str12AMList += "," + "<a href=\"javascript:EditStubCode(" + 
							(String)vRetResult.elementAt(i+6) + ")\">" + 
							(String)vRetResult.elementAt(i+6) + "</a>";
		}
	   
      while (
	      (i+22)< vRetResult.size() && 
    	  strTempIndex.equals((String)vRetResult.elementAt(i+28)) &&
	      vRetResult.elementAt(i+8).equals(vRetResult.elementAt(i+30)) &&
	      vRetResult.elementAt(i+9).equals(vRetResult.elementAt(i+31)) &&
    	  ((vRetResult.elementAt(i+14) == null && vRetResult.elementAt(i+36)==null)  
	      || (vRetResult.elementAt(i+14) != null && vRetResult.elementAt(i+36)!=null 
	      && vRetResult.elementAt(i+14).equals(vRetResult.elementAt(i+36))) ))
	      {
	      	  strTempDay += astrDay[Integer.parseInt((String)vRetResult.elementAt(i+32))];
    	  	  i+=22;
	      }
	  }
	  
	  if (vRetResult.elementAt(i+8)!=null && vRetResult.elementAt(i+9) != null && iTimeDataFr != null
	  		 && iTimeDataTo != null){
	  	strTemp = comUtil.formatMinute(Integer.toString(iTimeDataFr[0])) +
		  		comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) + " - " +
	  			comUtil.formatMinute(Integer.toString(iTimeDataTo[0])) + 
				comUtil.formatMinute(Integer.toString(iTimeDataTo[1]));
		} else {
		 strTemp = "TBA";
		}
	  %>
      <td width="11%"><font size="1"> <%=strTemp%></font></td>
      <td width="8%"><font size="1"><%=WI.getStrValue(strTempDay,"TBA")%></font></td>
	  <td width="9%"><font size="1"><%=strTempRoom%></font></td>
<%
if (bIsDupe) 
	strTemp = "&nbsp;";
else
	if (vRetResult.elementAt(i+17)!=null)
		strTemp = WI.formatName((String)vRetResult.elementAt(i+18),
								(String)vRetResult.elementAt(i+19),
								(String)vRetResult.elementAt(i+20),4);
	else
		strTemp = "c/o";
%>
      <td width="20%"><font size="1"><%=strTemp%></font></td>
	  <%if (bIsDupe) 
		  	strTemp = "&nbsp;";
		else
	 		if (((String)vRetResult.elementAt(i+16)).equals("0"))
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"--");
			else
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13),"--");
	  %>	  
      <td width="4%"><font size="1"><%=strTemp%></font></td>
	  <%if (bIsDupe) 
		  	strTemp = "&nbsp;";
		else
	 		strTemp =  "<a href=\"javascript:EditStubCode(" + 
							(String)vRetResult.elementAt(i+6) + ")\">" + 
							(String)vRetResult.elementAt(i+6) + "</a>";
	  %>	  
      <td width="7%"><font style="font-size:11px"><strong><%=strTemp%></strong></font></td>
	  <%if (bIsDupe) 
		  	strTemp = "&nbsp;";
		else
	 		strTemp =  WI.getStrValue((String)vRetResult.elementAt(i+11),"--"); 
	  %>	  
      <td width="4%"><font size="1"><%=strTemp%></font>
	  </td>
	  <%if (bIsDupe) 
		  	strTemp = "";
		else
			strTemp = ((String)vRetResult.elementAt(i+21)).substring(0,3);
	  %>		  
	  <td width="5%"><font size="1">&nbsp;<%=strTemp%></font></td>	  
    </tr>
<%  }//for(int i = 0 ; i< vRetResult.size() ; i+=21) %>
  </table>

<%}//end of view all display%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <%if (vRetResult!= null && vRetResult.size()>0){
 
 	 if (str12AMList.length() > 0) {
 %>
    <tr>
      <td height="25" colspan="2" bgcolor="#F99797">
		&nbsp;<strong>Please check the time of this stub codes (12AM) : <%=str12AMList%>	  </strong></td>
    </tr>
<%}%>
    <tr>
      <td width="61%" height="35">&nbsp;</td>
      <td width="39%" height="35" align="right"><font size="1">Rows per page</font>&nbsp;
        <%strTemp = WI.fillTextValue("row_ppg2");%>
        <select name="row_ppg2" style="font-size:11px" onChange="updateRowPerPage(2);">
          <option value="25">25</option>
          <%if (strTemp.equals("30")) {%>
          <option value="30" selected>30</option>
          <%} else {%>
          <option value="30">30</option>
          <%} if (strTemp.equals("35")) {%>
          <option value="35" selected>35</option>
          <%} else {%>
          <option value="35">35</option>
          <%} if (strTemp.equals("40")) {%>
          <option value="40" selected>40</option>
          <%} else {%>
          <option value="40">40</option>
          <%} if (strTemp.equals("45")) {%>
          <option value="45" selected>45</option>
          <%} else {%>
          <option value="45">45</option>
          <%} if (strTemp.equals("50")) {%>
          <option value="50" selected>50</option>
          <%} else {%>
          <option value="50">50</option>
          <%} if (strTemp.equals("55")) {%>
          <option value="55" selected>55</option>
          <%} else {%>
          <option value="55">55</option>
          <%} %>
        </select>
      &nbsp;&nbsp; <a href="javascript:PrintPage()"><img src="../../../../images/print.gif" border="0"></a></td>
    </tr>
   <%}%>	
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>	
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
<input type="hidden" name="print_pg">
<input type="hidden" name="get_status" value ="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>