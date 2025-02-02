<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime, eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Validate / Approved Overtime</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
    }

</style>
</head>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	int i = 3;
	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OVERTIME MANAGEMENT-Approve Overtime(Batch)","batch_approve_ot.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(), 
														"batch_approve_ot.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Approve Overtime",request.getRemoteAddr(), 
														"batch_approve_ot.jsp");	
}														
// added for CLDHEI.. 
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome)
		iAccessLevel = 2;
}

if (strTemp == null) 
	strTemp = "";

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../commfile/unauthorized_page.jsp");
	return;
}
	//end of authenticaion code.
	OverTime OT = new OverTime();
	Vector vRetResult = null;
	ReportEDTR RE = new ReportEDTR(request);
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Requested By","Date of Request","Date of OT", "No of Hours","Status", "Last Name(Requested for)"};
	String[] astrSortByVal     = {"head_.lname","request_date","ot_specific_date","no_of_hour","approve_stat", "sub_.lname"};

	
	String strDateFrom = WI.fillTextValue("DateFrom");
	String strDateTo = WI.fillTextValue("DateTo");
	int iSearchResult = 0;
	
	if (strDateFrom.length() ==0){
		String[] astrCutOffRange = eDTRUtil.getCurrentCutoffDateRange(dbOP,true);
		if (astrCutOffRange!= null && astrCutOffRange[0] != null){
			strDateFrom = astrCutOffRange[0];
			strDateTo = astrCutOffRange[1];
		}
	}

	if (WI.fillTextValue("save_record").equals("1")){
		if(!OT.batchUpdateOvertimeStat(dbOP,request))
			strErrMsg = OT.getErrMsg();
		else
			strErrMsg = "Overtime Request status Updated Successfully";
	} 
 
	vRetResult = RE.searchOvertime(dbOP, true);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
	else
		iSearchResult = RE.getSearchCount();
%>
<form action="./batch_approve_ot.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr >
      <td width="100%" height="25"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    
    <tr >
      <td height="25"><table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
		<%
			strTemp= WI.fillTextValue("view_all");
			if(strTemp.length() > 0)	
				strTemp = "checked";
			else
				strTemp = "";
		%>
    <td height="26" colspan="4" bgcolor="#FFFFFF"><input type="checkbox" name="view_all" value="1" <%=strTemp%>> View All</td>
  </tr>
  <tr>
    <td  width="10%" bgcolor="#FFFFFF"><strong>Sort By </strong></td>
    <td width="28%" bgcolor="#FFFFFF"><select name="sort_by1">
      <option value="" selected>N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
					if(WI.fillTextValue("sort_by1").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    <td width="28%" bgcolor="#FFFFFF"><select name="sort_by2">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
				if(WI.fillTextValue("sort_by2").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    <td width="34%" bgcolor="#FFFFFF"><select name="sort_by3">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <% if(WI.fillTextValue("sort_by3").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
  </tr>
  <tr>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table> </td>
    </tr>
  </table>
<% 
	if (vRetResult != null && vRetResult.size()>3) { %>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  
  <tr>
    <td align="right"> <%
		if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/RE.defSearchSize;
		if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> Jump To page:
        <select name="jumpto" onChange="ReloadPage();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%
					}
			}
			%>
        </select>
      <%}
			}%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
      <tr>
        <td width="18%" align="center" class="thinborder"><strong><font size="1">Requested 
          by </font></strong></td>
        <td width="18%" align="center" class="thinborder"><font size="1"><strong>Requested 
          For</strong></font></td>
        <td width="12%" align="center" class="thinborder"><font size="1"><strong>Date 
          of Request</strong></font></td>
        <td width="14%" align="center" class="thinborder"><font size="1"><strong>OT 
          Date</strong></font></td>
        <td width="12%" align="center" class="thinborder"><font size="1"><strong>Inclusive 
          Time</strong></font></td>
        <td width="7%" align="center" class="thinborder"><font size="1"><strong>No. 
        of Hours</strong></font></td>
        <td width="10%" align="center" class="thinborder"><font size="1"><strong>Reason</strong></font></td>
        <% if (iAccessLevel == 2) {%> 
        <%}%> 
      </tr>
      <tr>
        <%
			int iCtr = 1;
			for (i=0 ; i < vRetResult.size(); i+=35, iCtr++){ 
			strTemp2 = WI.formatName((String)vRetResult.elementAt(i+15), 
								(String)vRetResult.elementAt(i+16), (String)vRetResult.elementAt(i+17), 4);
		 	strTemp = (String)vRetResult.elementAt(i);
			strTemp = WI.getStrValue(strTemp);
		 %>
        <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp2, "", "(" + strTemp + ")","")%>
          <input type="hidden" name="ot_index_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+14)%>"></td>
        <% if (strTemp.equals((String)vRetResult.elementAt(i+1)))
						strTemp = "&nbsp;";
					else{
						strTemp = WI.formatName((String)vRetResult.elementAt(i+18), 
											(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
						strTemp += "(" + (String)vRetResult.elementAt(i+1) + ")";
					}
				%>
        <td class="thinborder">&nbsp;<%=strTemp%></td>
        <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
        <% 
		   		strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+4);
			    }else{
					strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
							" - " +	(String)vRetResult.elementAt(i+5) + ")";
				}
			%>
        <td align="center" class="thinborder">          <%=strTemp%></td>
        <td align="center" class="thinborder">
					<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                               (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - <br>
                  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
        <td class="thinborder">
					<input type="text" name="no_of_hours_<%=iCtr%>" class="textbox" maxlength="4" size="4"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					 value="<%=(String)vRetResult.elementAt(i+3)%>"
					 style="text-align:right"></td>
				<%
					strTemp = (String)vRetResult.elementAt(i+29);
					strTemp = WI.getStrValue(strTemp,"&nbsp;");
				%>
        <td class="thinborder"><%=strTemp%></td>
        <%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp.equals("1")){ 
					strTemp = "<strong><font color='#0000FF'> APPROVED </font></strong>";
				}else if (strTemp.equals("0")){
					strTemp = "<strong><font color='#FF0000'> DISAPPROVED </font></strong>";
				}else
					strTemp = "<strong> PENDING </strong>";
			%>
        <% if (iAccessLevel == 2) {%> 		
        <%}%> 
      </tr>
      <%}%>
 		<input type="hidden" name="max_items" value="<%=iCtr-1%>"> 
  </table>		
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
<!-- disable print 
    <tr > 
      <td height="25" align="center">
		<a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a></td>
    </tr>	
-->
  </table>
   <%}%>
   <input type="hidden" name="print_page">  
	<input type="hidden" name="save_record">  
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="from_batch" value="1">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>