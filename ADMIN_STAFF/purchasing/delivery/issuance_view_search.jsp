<%@ page language="java" import="utility.*,purchasing.IssuanceMgmt,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();		
	///added code for HR/companies.
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage(){	
    document.form_.printPage.value = "";	
 	this.SubmitOnce('form_');
}


function PrintIssuance(strIssuanceNo, strPONo){
	//var pgLoc = "./issuance_form_print.jsp?po_no="+strIssuanceNo;//use this to get only the issuance info
	var pgLoc = "./issuance_form_print.jsp?po_no="+strPONo+
		"&issuance_no="+strIssuanceNo;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
<%if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strID)
{
	window.opener.document.<%=strFormName%>.proceedClicked.value=1;
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strID;	
	window.opener.focus();
	<%
	if(strFormName != null){%>	
	window.opener.document.<%=strFormName%>.submit();	
	<%}%>	
	self.close();
}<%}%>
</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
 	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-ISSUANCE","issuance_view_search.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	
	
	IssuanceMgmt issueMgmt = new IssuanceMgmt();
	Vector vRetResult = null;
	
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	String strCollDiv = null;
	if(bolIsSchool)
		 strCollDiv = "College";
	else
		 strCollDiv = "Division";	
	String[] astrSortByName    = {"Issuance No.","PO No.","PO Status",strCollDiv,"Department"};
	String[] astrSortByVal     = {"ISSUANCE_NUMBER","PO_NUMBER","PO_STATUS","C_CODE","D_name"};
	
	
	
	int iSearch = 0;
	int iDefault = 0;
	int iElemCount = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = issueMgmt.searchIssuanceList(dbOP,request);
		if(vRetResult == null)
			strErrMsg = issueMgmt.getErrMsg();
		else{
			iSearch = issueMgmt.getSearchCount();
			iElemCount = issueMgmt.getElemCount();
		}
	}
	
%>
<form name="form_" method="post" action="issuance_view_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    
	
	<tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: ISSUANCE FORM SEARCH PAGE ::::</strong></font></div></td>
    </tr>
	
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="15%" height="25">Issuance No. : </td>
      <td width="40%" height="25"><select name="issuance_no_select">
          <%=issueMgmt.constructGenericDropList(WI.fillTextValue("issuance_no_select"),astrDropListEqual,astrDropListValEqual)%> 
		  </select> <input type="text" name="issuance_no" class="textbox" value="<%=WI.fillTextValue("issuance_no")%>"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">       </td>
      <td width="18%"></td>
      <td width="26%"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">PO No. : </td>
      <td height="25">      
	  
	   <select name="po_no_select">
          <%=issueMgmt.constructGenericDropList(WI.fillTextValue("po_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  	<input type="text" name="po_no" class="textbox" value="<%=WI.fillTextValue("po_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      <td height="25"></td>
      <td height="25"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Requested by :</td>
      <td height="25" colspan="2"><select name="req_by_select">
          <%=issueMgmt.constructGenericDropList(WI.fillTextValue("req_by_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_by" class="textbox" value="<%=WI.fillTextValue("req_by")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td height="25"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%> :</td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").equals("0")){%>
          <option value="0" selected>Non-Academic Office</option>
          <%}else{%>
          <option value="0">Non-Academic Office</option>
          <%} 
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp = WI.fillTextValue("c_index");
			else
				strTemp = "0";
			
			if(strTemp.compareTo("0") ==0)
				strTemp2 = "Offices";
			else
				strTemp2 = "Department";
			%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td colspan="3"> <%String strTemp3 = null;
		if(strTemp.compareTo("0") ==0) //only if non college show others.
			strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
		else
			strTemp2 = "";
	  %> <select name="d_index">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").length() < 1)
				strTemp = "-1";
			else
				strTemp3 = WI.fillTextValue("d_index");
		%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Issuance Date</td>
      <td colspan="3">
        <%strTemp = WI.fillTextValue("issue_date_fr");%>
        <input name="issue_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.issue_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("issue_date_to");%>
        <input name="issue_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.issue_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Supplier</td>
      <td colspan="3">
	  <select name="supplier_r" style="font-size:11px;">
      	<option value="">All</option>
<%
strTemp = " from PUR_SUPPLIER_PROFILE where is_del = 0 and exists (select * from pur_po_item where pur_po_item.supplier_index = PUR_SUPPLIER_PROFILE.profile_index) "+
			"order by supplier_name";
%>
        	<%=dbOP.loadCombo("profile_index","supplier_name",strTemp, WI.fillTextValue("supplier_r"), false)%> 
	  </select>	  </td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0" height="26">&nbsp;</td>
      <td colspan="4"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="8">&nbsp;</td>
      <td width="24%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=issueMgmt.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=issueMgmt.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select></td>
      <td width="24%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=issueMgmt.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td><select name="sort_by4">
          <option value="">N/A</option>
          <%=issueMgmt.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(false && !(WI.fillTextValue("opner_info").length() > 0)){%>
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of Issuance(s) Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1"> click to print list&nbsp;</font></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=issueMgmt.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/issueMgmt.defSearchSize;
		int iTotalItems = 0;
		double dTotalAmount = 0d;
		if(iSearch % issueMgmt.defSearchSize > 0) ++iPageCount;		
		%>
		&nbsp;</td>
		
      <td> <div align="right">
	  <%
		if(iPageCount > 1)
		{%>
	  Jump to page: 
          <select name="jumpto" onChange="ProceedClicked();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" colspan="2" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF ISSUANCE(S)</strong></font></div></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="10%" height="25" class="thinborder"><div align="center"><strong>ISSUANCE DATE</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><strong>PO NO.</strong></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>ISSUANCE NO.</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%> / 
          DEPT</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>OFFICE</strong></div></td>
      <!--<td width="8%" class="thinborder"><div align="center"><strong>PO STATUS</strong></div></td>-->
      <td width="7%" class="thinborder"><div align="center"><strong>TOTAL ITEMS </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
      <%if(WI.fillTextValue("opner_info").length() == 0){%>
	  <td width="5%" class="thinborder"><div align="center"><strong>VIEW</strong></div></td><%}%>
    </tr>
    <%for(int iLoop = 1;iLoop < vRetResult.size();iLoop+=iElemCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(iLoop)%></td>
      <td class="thinborder">
	  	<%if(WI.fillTextValue("opner_info").length() > 0) {%>
          <a href="javascript:CopyID('<%=(String)vRetResult.elementAt(iLoop+1)%>');"><%=(String)vRetResult.elementAt(iLoop+1)%></a> 
          <%}else{%><%=(String)vRetResult.elementAt(iLoop+1)%><%}%>	  
	  </td>
	  <%
	  if((String)vRetResult.elementAt(iLoop+3) != null)
		  strTemp = WI.getStrValue((String)vRetResult.elementAt(iLoop+3),"N/A") + WI.getStrValue((String)vRetResult.elementAt(iLoop+4),"All");		 
	  else
	  	strTemp = "N/A";	 
	  %>
	  
      <td class="thinborder"><%=strTemp%></td>
	  <%
	  if((String)vRetResult.elementAt(iLoop+3) != null)
		 strTemp = "N/A";
	  else
	  	 strTemp = WI.getStrValue((String)vRetResult.elementAt(iLoop+4),"&nbsp;");
	  %>
      <td class="thinborder"><%=strTemp%></td>
      <!--<td class="thinborder"><div align="left"><%//=astrPOStatus[Integer.parseInt((String)vRetResult.elementAt(iLoop+7))]%></div></td>-->
	  
      <td class="thinborder"  align="center"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+5),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+6),true)%></div></td>
      <%
	  if(WI.fillTextValue("opner_info").length() == 0){
	  %>
	  <td class="thinborder"><div align="center">
          <a href="javascript:PrintIssuance('<%=(String)vRetResult.elementAt(iLoop+1)%>','<%=(String)vRetResult.elementAt(iLoop)%>');">
		  	<img src="../../../images/view.gif" border="0" ></a></div></td><%}%>
    </tr>
	
    <%  
		
		
		iTotalItems += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(iLoop+5),"0"));    				
		dTotalAmount += Double.parseDouble(WI.getStrValue(vRetResult.elementAt(iLoop+6),"0"));   
	}//end of loop
	
	if(WI.fillTextValue("opner_info").length() == 0){%>
    <tr> 
      <td  height="25" colspan="5" class="thinborder"> <div align="right"><strong>PAGE  TOTAL :&nbsp;&nbsp;&nbsp;</strong></div></td>
      <td class="thinborder"><div align="center"><strong><%=iTotalItems%></strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong></div></td>
      <td rowspan="2" class="thinborder">&nbsp;</td>
    </tr>
	<tr>
    <td class="thinborder" height="25" colspan="5"><div align="left"></div>
      <div align="right"><strong>OVERALL SEARCH TOTAL :&nbsp; &nbsp;&nbsp;</strong></div></td>
    <td height="25" colspan="2" class="thinborder"><div align="right"></div>
      <div align="right"><strong><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(0),"0"),true)%></strong></div></td>
  	</tr>
	<%}%>
  </table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
 <%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
