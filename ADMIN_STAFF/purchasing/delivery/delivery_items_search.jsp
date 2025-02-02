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
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage(){	
    document.form_.printPage.value = "";	
 	this.SubmitOnce('form_');
}
function ViewItem(strIndex,strCode){
	var pgLoc = "delivery_status_view.jsp?req_no="+strIndex+"&supplier_code="+strCode;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./delivery_items_search_print.jsp"/>
	<%}
	
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery search","delivery_items_search.jsp");
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
	
	Delivery DEL = new Delivery();
	Vector vRetResult = null;
	String[] astrPORecStatus = {"Not Received","Received (All)","Received (Partial)"};
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"","Supplier Code","Date Received"};
	String[] astrSortByVal     = {"PO_NUMBER","supplier_code","date_received"};

	String strSupply = WI.fillTextValue("is_supply");
	String[] astrSupplyVal = {"0","1","2","3"};
	String[] astrSupplyType = {"Non-Supplies / Equipmment","Supplies","Chemical","Computers/Parts"};
		
	String strInvoice = null;
	String strDateReceived = null;
	String strTotalItem = null;
	String strTotal = null;
	
	
	int iSearch = 0;
	int iDefault = 0;
	boolean bolShowView = true;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = DEL.searchDeliveriesBySupplier(dbOP,request);
		if(vRetResult == null)
			strErrMsg = DEL.getErrMsg();
		else
			iSearch = DEL.getSearchCount();		
	}
%>
<form name="form_" method="post" action="delivery_items_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - SEARCH/VIEW DELIVERIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(false){%>
    <!--
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">College :</td>
      <td width="77%"><select name="c_index" onChange="ReloadPage();">
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
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td> <%String strTemp3 = null;
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
	-->
    <%}%>
    <tr>
      <td width="3%" height="27">&nbsp;</td>
      <td width="15%">Supplier :</td>
      <td width="82%"><%if(WI.fillTextValue("supplier").length() > 0)
	  		strTemp = WI.fillTextValue("supplier");
		else
			strTemp = "";%>
          <select name="supplier">
            <option value="">All</option>
            <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_NAME"," from PUR_SUPPLIER_PROFILE " +
		  "where is_del = 0 order by SUPPLIER_NAME asc", strTemp, false)%>
        </select></td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Inventory Type : </td>
	  <%
	  	strSupply = WI.fillTextValue("is_supply");
	  %>
      <td><select name="is_supply" onChange="ReloadPage();">
	    <option value="">ALL</option>
        <%for(int i = 0; i < 4; i++){%>
			<%if(strSupply.equals(Integer.toString(i))){%>
			<option value="<%=i%>" selected><%=astrSupplyType[i]%></option>
			<%}else{%>
			<option value="<%=i%>"><%=astrSupplyType[i]%></option>
			<%}%>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Category : </td>
      <td><%if(WI.fillTextValue("cat_index").length() > 0)
	  		strTemp = WI.fillTextValue("cat_index");
		else
			strTemp = "";%>
        <select name="cat_index" onChange="ReloadPage();">
        <option value="">All</option>
        <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					WI.getStrValue(strSupply,"where is_supply_cat = ","","") + 
							"order by inv_category", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Item :</td>
      <td><%if(WI.fillTextValue("item").length() > 0)
	  		strTemp = WI.fillTextValue("item");
		else
			strTemp = "";
			%>
          <select name="item" onChange="ReloadPage();">
            <option value="">All</option>
            <%=dbOP.loadCombo("ITEM_INDEX","ITEM_NAME"," from PUR_PRELOAD_ITEM " +
							WI.getStrValue(WI.fillTextValue("cat_index"),"where inv_cat_index = ","","") + 
							"order by ITEM_NAME asc", strTemp, false)%>
        </select></td>
    </tr>
    <%if(WI.fillTextValue("item").length() > 0){%>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Brand :</td>
      <td><%strTemp = WI.fillTextValue("brand");%>
          <select name="brand">
            <option value="">All</option>
            <%=dbOP.loadCombo("brand_index","brand_name"," from pur_preload_brand order by brand_name asc", strTemp, false)%>
          </select>      </td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<!--
    <tr> 
      <td width="0" height="26">&nbsp;</td>
      <td colspan="4"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="8">&nbsp;</td>
      <td width="24%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=DEL.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=DEL.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="24%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=DEL.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td><select name="sort_by4">
          <option value="">N/A</option>
          <%=DEL.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
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
	-->
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="97%" colspan="4">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="2"><div align="right">
        
        Number of PO(s) Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPage();"> 
		  <img src="../../../images/print.gif" border="0"></a> 
          <font size="1"> click to print list&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  	<!--
	<tr> 
      <td height="10">	  
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=DEL.getDisplayRange()%>)</font></strong>
		&nbsp;
		</td>
    </tr> 
	-->
	<tr> 
      <%
		int iPageCount = iSearch/DEL.defSearchSize;		
		if(iSearch % DEL.defSearchSize > 0) ++iPageCount;		
		if(iPageCount >= 1)
		{%>	
      <td height="10"> <div align="right">Jump to page: 
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
         
        </div></td> <%}%>
    </tr>  	 
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
	  <div align="center"><font color="#FFFFFF"><strong>LIST OF PO DELIVERIES PER SUPPLIER </strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="25%" height="25" class="thinborder"><div align="center"><strong>SUPPLIER </strong></div></td>
      <td width="36%" class="thinborder"><div align="center"><strong>ITEM / BRAND </strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>QTY / UNIT </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>UNIT PRICE </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT </strong></div></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size();i+=8){%>
    <tr> 
      <td height="20" class="thinborder"><div align="left">&nbsp;
	      <%
		  if (i > 0 && ((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i-8))){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(i+1)%> 
          <%}%>	  
	  </div></td>
	  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"/","","")%></td>
      <td class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;<%=(String)vRetResult.elementAt(i+5)%>&nbsp;</div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true)%>&nbsp;</div></td>	  
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true)%>&nbsp;</div></td>
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
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
